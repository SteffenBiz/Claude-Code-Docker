# Claude Code Docker Environment

Eine produktionsreife Docker-Umgebung für Claude Code mit vollständiger Entwicklungsumgebung, MCP-Server Integration und gemeinsamer Obsidian-Wissensdatenbank.

## 🎯 Was ist das?

Dieses Projekt bietet eine vollständige Docker-basierte Entwicklungsumgebung für Claude Code mit:

- **Volle Autonomie**: Claude hat sudo-Rechte für selbstständiges Arbeiten
- **Moderne Webentwicklung**: Alle wichtigen Sprachen, Frameworks und Tools vorinstalliert
- **MCP Server Integration**: Filesystem, GitHub API und MariaDB Zugriff
- **Gemeinsame Wissensdatenbank**: Obsidian-basierte Dokumentation auf Deutsch
- **Git/GitHub Integration**: SSH-Agent Forwarding für nahtlose Repository-Arbeit
- **E-Mail-Versand**: SMTP-Unterstützung für Benachrichtigungen
- **Docker-in-Docker**: Claude kann eigene Container verwalten

## 🚀 Schnellstart

```bash
# 1. Repository klonen
git clone https://github.com/SteffenBiz/Claude-Code-Docker.git
cd Claude-Code-Docker

# 2. Umgebung prüfen
./check-environment.sh

# 3. Konfiguration anpassen
cp .env.example .env
nano .env  # Passwörter ändern!

# 4. Container starten
docker-compose up -d

# 5. Claude Code verwenden
docker exec -it claude-code-docker bash
```

## 📋 Voraussetzungen

- Docker & Docker Compose
- SSH-Key für GitHub (mit ssh-agent)
- Claude Code CLI auf dem Host
- Optional: GitHub CLI (`gh`) authentifiziert

## 🛠️ Verfügbare Tools

### Programmiersprachen
- **JavaScript/TypeScript**: Node.js 20, Deno, Bun
- **Python 3**: Mit Django, Flask, FastAPI
- **PHP**: Mit Composer und allen Extensions
- **Ruby**, **Go**, **Rust**

### Entwicklungstools
- **Build**: Webpack, Vite, Parcel, Rollup
- **Frameworks**: Angular, Vue, React, NestJS
- **Testing**: Jest, Cypress, pytest
- **Datenbanken**: MariaDB, PostgreSQL, Redis, SQLite
- **Container**: Docker CLI (Host-Zugriff)

## 💡 Wichtige Konzepte

### Arbeitsverzeichnisse
- `/volumes/workspace/` - Temporäre Dateien
- `/volumes/repositories/` - Git Repositories
- `/volumes/obsidian/` - Gemeinsame Wissensdatenbank

### SSH-Verbindungen
Alle SSH-Verbindungen vom Host funktionieren auch im Container:
```bash
ssh myserver  # Nutzt Host SSH-Config und Keys
```

### MCP Server
MCP-Server werden auf dem Host konfiguriert:
```bash
# Auf dem Host
claude mcp add filesystem -- npx -y @modelcontextprotocol/server-filesystem /path

# Im Container verfügbar
claude mcp list
```

## 📚 Obsidian Wissensdatenbank

Die Wissensdatenbank ist ein **gemeinsames Gedächtnis** zwischen dir und Claude:
- Organische Struktur, die mit den Projekten wächst
- Qualität vor Quantität - nur wichtige Informationen
- Auf Deutsch, gut vernetzt mit [[Wikilinks]]
- Respektiere bestehende Notizen

## 🔧 Konfiguration

### Environment Variables (.env)
```env
# Datenbank
MYSQL_ROOT_PASSWORD=dein_root_passwort
MYSQL_PASSWORD=dein_claude_passwort

# E-Mail (optional)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=user@example.com
SMTP_PASS=smtp_passwort
SMTP_FROM=claude@example.com
```

### Umgebung prüfen
```bash
# Auf Host oder im Container
./check-environment.sh
```

## 🐳 Container Management

```bash
# Status
docker-compose ps

# Logs
docker-compose logs -f

# Neustart
docker-compose restart

# Rebuild
docker-compose build --no-cache
```

## 🔍 Troubleshooting

**SSH-Agent funktioniert nicht?**
```bash
ssh-add -l  # Muss Keys zeigen
echo $SSH_AUTH_SOCK  # Muss gesetzt sein
```

**MCP Server fehlen?**
- MCP werden auf dem Host konfiguriert
- Container übernimmt automatisch die Host-Konfiguration

**MariaDB nicht erreichbar?**
```bash
docker-compose exec mariadb mysql -u root -p
```

## 📁 Projektstruktur

```
├── docker-compose.yml    # Container-Orchestrierung
├── Dockerfile           # Claude's Umgebung
├── CLAUDE.md           # Anweisungen für Claude
├── check-environment.sh # Umgebungs-Check
├── volumes/            # Persistente Daten
│   ├── workspace/      # Arbeitsbereich
│   ├── repositories/   # Git Repos
│   └── obsidian/       # Wissensdatenbank
└── docs/               # Weitere Dokumentation
```

## 🔒 Sicherheit

- Ändere ALLE Passwörter in `.env`
- SSH-Keys bleiben sicher auf dem Host
- `.env` niemals committen!
- Nur für Entwicklung, nicht für Produktion

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE)

---

🤖 Erstellt für autonomes Arbeiten mit Claude Code