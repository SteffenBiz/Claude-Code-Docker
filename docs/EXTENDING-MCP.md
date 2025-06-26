# MCP Server erweitern

Diese Anleitung zeigt, wie du weitere MCP Server zum Claude Code Docker System hinzufügst.

## 🎯 Übersicht

Es gibt verschiedene Möglichkeiten, MCP Server hinzuzufügen:

1. **Offiziell verfügbare MCP Server** - Aus npm/GitHub installieren
2. **Eigene MCP Server** - Selbst entwickelte Server
3. **Remote MCP Server** - Externe Server über HTTP/SSE

## 📦 Methode 1: Offizielle MCP Server hinzufügen

### Schritt 1: Server zum Dockerfile hinzufügen

Bearbeite `Dockerfile` und füge den Server zur npm Installation hinzu:

```dockerfile
# Claude Code und MCP Server global installieren
RUN npm install -g \
    @anthropic-ai/claude-code \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-github \
    @benborla29/mcp-server-mysql \
    @modelcontextprotocol/server-sqlite \    # NEU: SQLite Server
    @modelcontextprotocol/server-postgres    # NEU: PostgreSQL Server
```

### Schritt 2: configure-mcp.sh erweitern

Füge die Konfiguration in `scripts/configure-mcp.sh` hinzu:

```bash
# Nach den bestehenden Servern hinzufügen:
    },
    "sqlite": {
      "command": "node",
      "args": [
        "/usr/lib/node_modules/@modelcontextprotocol/server-sqlite/dist/index.js",
        "/workspace/data/app.db"
      ]
    },
    "postgres": {
      "command": "node",
      "args": [
        "/usr/lib/node_modules/@modelcontextprotocol/server-postgres/dist/index.js"
      ],
      "env": {
        "POSTGRES_HOST": "postgres",
        "POSTGRES_PORT": "5432",
        "POSTGRES_USER": "claude",
        "POSTGRES_PASSWORD": "$POSTGRES_PASSWORD",
        "POSTGRES_DB": "claude_db"
      }
    }
```

### Schritt 3: Docker Compose erweitern (falls nötig)

Für Datenbank-Server, füge den Service zu `docker-compose.yml` hinzu:

```yaml
  postgres:
    image: postgres:15
    container_name: claude-postgres
    environment:
      POSTGRES_USER: claude
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: claude_db
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - claude-network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U claude"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  postgres-data:
```

### Schritt 4: Rebuild und Test

```bash
# Image neu bauen
docker-compose build

# Container neu starten
docker-compose down && docker-compose up -d

# Testen
docker exec claude-code-docker claude mcp list
```

## 🔧 Methode 2: Eigene MCP Server entwickeln

Für die Entwicklung eigener MCP Server siehe die offizielle Dokumentation:
- [MCP SDK Dokumentation](https://modelcontextprotocol.io/docs/server/sdk)
- [MCP Server Beispiele](https://github.com/modelcontextprotocol/servers)

Eigene Server können als Volume gemountet und in der MCP-Konfiguration hinzugefügt werden.

## 🌐 Methode 3: Remote MCP Server

### HTTP/SSE Server hinzufügen

Remote Server benötigen keine Installation im Container:

```bash
# Im Container oder auf dem Host
claude mcp add weather-remote \
  --transport sse \
  --scope user \
  https://api.example.com/mcp/weather
```

Oder in `settings.json`:

```json
{
  "mcpServers": {
    "weather-remote": {
      "transport": "sse",
      "url": "https://api.example.com/mcp/weather",
      "headers": {
        "Authorization": "Bearer ${WEATHER_API_KEY}"
      }
    }
  }
}
```

## 🛠️ Praktische Beispiele

### 1. Brave Search MCP

```bash
# Zum Dockerfile hinzufügen
RUN npm install -g @modelcontextprotocol/server-brave-search

# Environment Variable in docker-compose.yml
environment:
  - BRAVE_API_KEY=${BRAVE_API_KEY}

# In configure-mcp.sh
"brave-search": {
  "command": "node",
  "args": ["/usr/lib/node_modules/@modelcontextprotocol/server-brave-search/dist/index.js"],
  "env": {
    "BRAVE_API_KEY": "${BRAVE_API_KEY}"
  }
}
```

### 2. Slack MCP

```bash
# Installation
RUN npm install -g @modelcontextprotocol/server-slack

# Konfiguration
"slack": {
  "command": "node",
  "args": ["/usr/lib/node_modules/@modelcontextprotocol/server-slack/dist/index.js"],
  "env": {
    "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}",
    "SLACK_TEAM_ID": "${SLACK_TEAM_ID}"
  }
}
```

### 3. Memory/Knowledge Graph MCP

```bash
# Für persistente Wissensspeicherung
"memory": {
  "command": "node",
  "args": [
    "/usr/lib/node_modules/@modelcontextprotocol/server-memory/dist/index.js",
    "/obsidian/.mcp-memory"
  ]
}
```

## 📋 Best Practices

### 1. Environment Variables

Füge neue Secrets zu `.env.example` hinzu:

```env
# Neue MCP Server
BRAVE_API_KEY=your-brave-api-key
SLACK_BOT_TOKEN=xoxb-your-token
WEATHER_API_KEY=your-weather-key
```

### 2. Dokumentation

Erstelle für jeden neuen Server eine Datei in `docs/mcp-servers/`:

```markdown
# Weather MCP Server

## Beschreibung
Bietet Wetterdaten für Claude Code.

## Installation
Bereits im Docker Image enthalten.

## Verwendung
cf "Wie ist das Wetter in Berlin?"

## Konfiguration
Benötigt WEATHER_API_KEY in .env
```

### 3. Testing

Füge Tests zu `check-setup.sh` hinzu:

```bash
# Prüfe neue MCP Server
if [ -f "/usr/lib/node_modules/@modelcontextprotocol/server-weather/dist/index.js" ]; then
    echo -e "${GREEN}✓ Weather MCP Server installiert${NC}"
else
    echo -e "${YELLOW}⚠ Weather MCP Server fehlt${NC}"
fi
```

## 🔍 Verfügbare MCP Server finden

### Offizielle Quellen

1. **MCP Server Registry**: https://github.com/anthropics/mcp/wiki/MCP-Servers
2. **NPM Registry**: https://www.npmjs.com/search?q=%40modelcontextprotocol
3. **GitHub Topics**: https://github.com/topics/mcp-server

### Community Server

- https://github.com/topics/model-context-protocol
- https://github.com/search?q=mcp+server

## 🚀 Automatisierung

### Automatisierung

Für häufige MCP-Server-Erweiterungen empfiehlt es sich, ein eigenes erweitertes Dockerfile zu erstellen, das auf diesem Basis-Image aufbaut.

## 🎯 Nächste Schritte

1. Wähle MCP Server aus der Registry
2. Folge der passenden Methode oben
3. Teste im Container
4. Dokumentiere für andere Nutzer

Mit diesem System kannst du beliebig viele MCP Server hinzufügen und Claude Code's Fähigkeiten erweitern!