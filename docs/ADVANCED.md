# Erweiterte Konfiguration

Diese Anleitung beschreibt erweiterte Konfigurationsmöglichkeiten für Claude Code Docker.

## Profile anpassen

### Eigenes Profil erstellen

1. **Dockerfile erstellen**:
   ```dockerfile
   # dockerfiles/Dockerfile.custom
   FROM claude-code-docker:base
   
   USER root
   
   # Installiere deine Tools
   RUN apt-get update && apt-get install -y \
       your-tools \
       && rm -rf /var/lib/apt/lists/*
   
   ENV CLAUDE_PROFILE=custom
   
   USER claude
   WORKDIR /home/claude
   ```

2. **Service in docker-compose.yml hinzufügen**:
   ```yaml
   claude-custom:
     extends:
       service: claude-base
     build:
       context: .
       dockerfile: dockerfiles/Dockerfile.custom
     profiles: ["custom"]
     depends_on:
       mariadb:
         condition: service_healthy
   ```

3. **start-claude.sh erweitern**:
   - Füge "custom" zu `VALID_PROFILES` hinzu
   - Füge einen Case für profil-spezifische Hinweise hinzu

### Build-Optimierungen

#### Multi-Stage Builds

Für große Profile kannst du Multi-Stage Builds verwenden:

```dockerfile
# Build Stage
FROM claude-code-docker:base as builder
# Kompiliere Software
RUN build-commands

# Runtime Stage
FROM claude-code-docker:base
COPY --from=builder /path/to/binary /usr/local/bin/
```

#### Build Cache nutzen

```bash
# Mit BuildKit für besseres Caching
DOCKER_BUILDKIT=1 docker-compose build

# Nur bestimmte Stages neu bauen
docker build --target base -t claude-code-docker:base .
```

## Volume-Konfiguration

### Externe Volumes

Für große Datenmengen kannst du externe Volumes nutzen:

```yaml
volumes:
  large-data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /path/to/large/storage
```

### NFS Volumes

Für geteilte Entwicklung über Netzwerk:

```yaml
volumes:
  shared-repos:
    driver: local
    driver_opts:
      type: nfs
      o: addr=nfs-server.local,rw
      device: ":/exports/repositories"
```

## Netzwerk-Konfiguration

### Eigenes Netzwerk

```yaml
networks:
  development:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

### Container mit statischen IPs

```yaml
services:
  claude-web:
    networks:
      development:
        ipv4_address: 172.20.0.10
```

## Ressourcen-Limits

### CPU und Memory Limits

```yaml
services:
  claude-python:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
        reservations:
          cpus: '1'
          memory: 2G
```

### GPU-Zugriff

Für Machine Learning Profile:

```yaml
services:
  claude-ml:
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
```

## Umgebungsvariablen

### Profil-spezifische .env Dateien

```bash
# .env.python
JUPYTER_PORT=8888
TENSORBOARD_PORT=6006

# Lade profil-spezifische ENV
set -a
source .env.$CLAUDE_PROFILE
set +a
```

### Secrets Management

Für sensible Daten verwende Docker Secrets:

```yaml
secrets:
  db_password:
    file: ./secrets/db_password.txt

services:
  claude-web:
    secrets:
      - db_password
    environment:
      - DB_PASSWORD_FILE=/run/secrets/db_password
```

## Health Checks

### Custom Health Checks

```yaml
services:
  claude-web:
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## Logging

### Zentralisiertes Logging

```yaml
services:
  claude-web:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
        labels: "profile=web"
```

### Logging an externe Systeme

```yaml
logging:
  driver: syslog
  options:
    syslog-address: "tcp://logserver:514"
    tag: "claude-{{.Name}}"
```

## Backup und Recovery

### Automatische Backups

```bash
#!/bin/bash
# scripts/backup.sh
BACKUP_DIR="/backup/$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Volumes sichern
docker run --rm \
  -v claude-code-docker_repositories:/source:ro \
  -v $BACKUP_DIR:/backup \
  alpine tar -czf /backup/repositories.tar.gz -C /source .

# Datenbank sichern
docker exec claude-mariadb \
  mysqldump -u root -p$MYSQL_ROOT_PASSWORD --all-databases \
  > $BACKUP_DIR/mariadb.sql
```

### Restore

```bash
# Volume wiederherstellen
docker run --rm \
  -v claude-code-docker_repositories:/target \
  -v $BACKUP_DIR:/backup:ro \
  alpine tar -xzf /backup/repositories.tar.gz -C /target

# Datenbank wiederherstellen
docker exec -i claude-mariadb \
  mysql -u root -p$MYSQL_ROOT_PASSWORD < $BACKUP_DIR/mariadb.sql
```

## Monitoring

### Container-Metriken mit Prometheus

```yaml
services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"
```

### Docker Stats exportieren

```bash
# Einfaches Monitoring
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# JSON Export für externe Tools
docker stats --format json > metrics.json
```

## CI/CD Integration

### GitHub Actions

```yaml
# .github/workflows/build.yml
name: Build Docker Images

on:
  push:
    branches: [main]
    paths:
      - 'dockerfiles/**'

jobs:
  build:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        profile: [web, java, python, pentest, media]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Build ${{ matrix.profile }} image
      run: |
        docker build -t claude-code-docker:${{ matrix.profile }} \
          -f dockerfiles/Dockerfile.${{ matrix.profile }} .
```

## Performance-Optimierungen

### Docker BuildKit

```bash
# In .env aktivieren
DOCKER_BUILDKIT=1
COMPOSE_DOCKER_CLI_BUILD=1
```

### Layer Caching

```dockerfile
# Änderungen am Ende platzieren
FROM claude-code-docker:base
# Selten ändernde Befehle zuerst
RUN apt-get update && apt-get install -y stable-packages
# Häufig ändernde Befehle später
COPY requirements.txt .
RUN pip install -r requirements.txt
```

## Sicherheit

### Read-Only Root Filesystem

```yaml
services:
  claude-web:
    read_only: true
    tmpfs:
      - /tmp
      - /var/run
    volumes:
      - ./app:/app:ro
```

### Capabilities begrenzen

```yaml
services:
  claude-web:
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
      - CHOWN
```

### User Namespace Remapping

In Docker Daemon Config (`/etc/docker/daemon.json`):

```json
{
  "userns-remap": "default"
}
```

## Troubleshooting

### Debug Mode

```bash
# Verbose Logging
COMPOSE_VERBOSE=true docker-compose up

# Container mit Shell starten
docker-compose run --rm claude-web bash

# Failing Container debuggen
docker-compose run --rm --entrypoint /bin/bash claude-web
```

### Performance Profiling

```bash
# CPU Profiling
docker stats --no-stream

# I/O Stats
docker exec claude-web iostat -x 1

# Netzwerk Stats
docker exec claude-web netstat -i
```