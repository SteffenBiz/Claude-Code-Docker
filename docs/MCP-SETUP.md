# MCP (Model Context Protocol) Server Setup

## Was ist MCP?

MCP ist ein offenes Protokoll, das Claude Code ermöglicht, mit externen Tools und Datenquellen zu kommunizieren. MCP-Server erweitern Claude's Fähigkeiten um spezifische Funktionalitäten.

## Konfiguration auf dem Host

MCP-Server werden **ausschließlich auf dem Host-System** konfiguriert und sind dann automatisch im Docker Container verfügbar.

### Speicherort der Konfiguration

Die MCP-Konfiguration wird in `~/.claude.json` gespeichert:

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "command",
      "args": ["arg1", "arg2"],
      "env": {
        "ENV_VAR": "value"
      }
    }
  }
}
```

### MCP-Server hinzufügen

Verwende den Claude CLI Befehl:

```bash
# Allgemeine Syntax
claude mcp add <name> [options] -- <command> [args...]

# Beispiel: Filesystem Server
claude mcp add filesystem \
  --scope user \
  -- npx -y @modelcontextprotocol/server-filesystem \
  /home/$USER/Documents /home/$USER/Downloads

# Beispiel: GitHub Server
claude mcp add github \
  --scope user \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -- npx -y @modelcontextprotocol/server-github

# Server auflisten
claude mcp list

# Server entfernen
claude mcp remove <name>
```

### Verfügbare MCP-Server

1. **Filesystem** - Dateizugriff
   ```bash
   npx -y @modelcontextprotocol/server-filesystem <path1> <path2> ...
   ```

2. **GitHub** - GitHub API Integration
   ```bash
   npx -y @modelcontextprotocol/server-github
   # Benötigt: GITHUB_TOKEN
   ```

3. **MariaDB/MySQL** - Datenbankzugriff
   ```bash
   npx -y @benborla29/mcp-server-mysql
   # Benötigt: MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, etc.
   ```

4. **Weitere Server**:
   - SQLite
   - PostgreSQL
   - Brave Search
   - Slack
   - Memory/Knowledge Graph

## Container-Integration

Die auf dem Host konfigurierten MCP-Server sind automatisch im Container verfügbar durch:

1. Mount von `~/.claude.json` nach `/home/claude/.claude.json`
2. Mount von `~/.claude/` nach `/home/claude/.claude/`

**Wichtig**: MCP-Server können NICHT im Container konfiguriert werden. Alle Konfiguration muss auf dem Host erfolgen.

## Troubleshooting

### Server nicht im Container sichtbar

1. Prüfe die Host-Konfiguration:
   ```bash
   claude mcp list
   cat ~/.claude.json | jq '.mcpServers'
   ```

2. Container neu starten:
   ```bash
   docker-compose down
   docker-compose up -d
   ```

3. Im Container prüfen:
   ```bash
   docker exec claude-code-docker check-environment.sh
   ```

### Fehlende Berechtigungen

Einige MCP-Server benötigen Zugriff auf Host-Ressourcen. Stelle sicher, dass:
- Pfade korrekt gemountet sind
- Environment-Variablen gesetzt sind
- Tokens/Credentials verfügbar sind

## Best Practices

1. **Minimale Berechtigungen**: Gib MCP-Servern nur Zugriff auf benötigte Ressourcen
2. **Environment-Variablen**: Nutze diese für Secrets statt Hardcoding
3. **Dokumentation**: Dokumentiere welche MCP-Server für welche Zwecke konfiguriert sind
4. **Testing**: Teste neue MCP-Server erst isoliert bevor du sie produktiv nutzt

## Weiterführende Informationen

- [MCP Dokumentation](https://modelcontextprotocol.io/docs)
- [MCP Server Registry](https://github.com/anthropics/mcp/wiki/MCP-Servers)
- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)