#!/bin/bash

# check-environment.sh - Universelles Check-Skript für Host und Container
# Funktioniert sowohl auf dem Host als auch im Container

# Farben für bessere Lesbarkeit
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Zähler für Fehler/Warnungen (nur für Host)
ERRORS=0
WARNINGS=0

echo "===================================="
echo "🔍 SYSTEM & UMGEBUNGS-CHECK"
echo "===================================="

# 1. Umgebung erkennen
if [ -f /.dockerenv ] || ([ -n "$HOSTNAME" ] && [ "$HOSTNAME" = "claude-code-docker" ]); then
    ENVIRONMENT="CONTAINER"
    echo -e "📍 Umgebung: ${GREEN}CONTAINER${NC}"
else
    ENVIRONMENT="HOST"
    echo -e "📍 Umgebung: ${BLUE}HOST${NC}"
fi

# 2. Benutzer und System
echo ""
echo "👤 SYSTEM-INFO:"
echo -e "  - Benutzer: ${GREEN}$(whoami)${NC}"
echo -e "  - Home: ${GREEN}$HOME${NC}"
echo -e "  - Arbeitsverzeichnis: ${GREEN}$(pwd)${NC}"

# 3. Wichtige Pfade prüfen
echo ""
echo "📂 VERFÜGBARE PFADE:"

# Volumes-Verzeichnisse
for dir in repositories workspace obsidian; do
    if [ -d "/home/claude/volumes/$dir" ]; then
        if [ -w "/home/claude/volumes/$dir" ]; then
            echo -e "  - /home/claude/volumes/$dir ${GREEN}(lesen/schreiben)${NC}"
        else
            echo -e "  - /home/claude/volumes/$dir ${YELLOW}(nur lesen)${NC}"
        fi
    elif [ "$ENVIRONMENT" = "HOST" ] && [ -d "./volumes/$dir" ]; then
        echo -e "  - ./volumes/$dir ${GREEN}(Host-Pfad)${NC}"
    else
        echo -e "  - /home/claude/volumes/$dir ${RED}(nicht vorhanden)${NC}"
        if [ "$ENVIRONMENT" = "HOST" ]; then
            ((WARNINGS++))
        fi
    fi
done

# 4. MCP-Server Status
echo ""
echo "🔧 MCP-SERVER:"
if command -v claude &> /dev/null; then
    # Prüfe ~/.claude.json
    if [ -f "$HOME/.claude.json" ] && grep -q "mcpServers" "$HOME/.claude.json" 2>/dev/null; then
        MCP_COUNT=$(grep -A50 "mcpServers" "$HOME/.claude.json" 2>/dev/null | grep -c '"type"' || echo "0")
        if [ "$MCP_COUNT" -gt 0 ]; then
            echo -e "  ${GREEN}✓ $MCP_COUNT MCP-Server konfiguriert${NC}"
        else
            echo -e "  ${YELLOW}⚠ MCP-Server Sektion vorhanden, aber keine Server${NC}"
            if [ "$ENVIRONMENT" = "HOST" ]; then
                ((WARNINGS++))
            fi
        fi
    else
        echo -e "  ${YELLOW}⚠ Keine MCP-Server konfiguriert${NC}"
        if [ "$ENVIRONMENT" = "HOST" ]; then
            echo "    Tipp: Verwende 'claude mcp add' um Server hinzuzufügen"
            ((WARNINGS++))
        else
            echo "    Info: MCP-Server müssen auf dem Host konfiguriert werden"
        fi
    fi
else
    echo -e "  ${RED}✗ Claude CLI nicht verfügbar${NC}"
    if [ "$ENVIRONMENT" = "HOST" ]; then
        ((ERRORS++))
    fi
fi

# 5. System-Zugänge
echo ""
echo "🔑 ZUGÄNGE & TOOLS:"

# SSH-Agent
if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
    echo -e "  - SSH-Agent: ${GREEN}✓ Verbunden${NC}"
    # SSH Keys prüfen
    if ssh-add -l &>/dev/null; then
        KEY_COUNT=$(ssh-add -l | wc -l)
        echo -e "    ${GREEN}$KEY_COUNT Schlüssel geladen${NC}"
    else
        echo -e "    ${YELLOW}Keine Schlüssel geladen${NC}"
        if [ "$ENVIRONMENT" = "HOST" ]; then
            ((WARNINGS++))
        fi
    fi
else
    echo -e "  - SSH-Agent: ${RED}✗ Nicht verfügbar${NC}"
    if [ "$ENVIRONMENT" = "HOST" ]; then
        ((WARNINGS++))
    fi
fi

# Docker
if [ -S /var/run/docker.sock ]; then
    if docker version &> /dev/null; then
        echo -e "  - Docker: ${GREEN}✓ Zugriff möglich${NC}"
    else
        echo -e "  - Docker: ${YELLOW}Socket vorhanden, aber kein Zugriff${NC}"
        if [ "$ENVIRONMENT" = "HOST" ]; then
            ((ERRORS++))
        fi
    fi
else
    echo -e "  - Docker: ${RED}✗ Nicht verfügbar${NC}"
    if [ "$ENVIRONMENT" = "HOST" ]; then
        ((ERRORS++))
    fi
fi

# Git
if command -v git &> /dev/null; then
    GIT_USER=$(git config --global user.name 2>/dev/null || echo "nicht konfiguriert")
    GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "nicht konfiguriert")
    if [ "$GIT_USER" != "nicht konfiguriert" ]; then
        echo -e "  - Git: ${GREEN}✓ Konfiguriert${NC}"
        echo -e "    Name: $GIT_USER, Email: $GIT_EMAIL"
    else
        echo -e "  - Git: ${YELLOW}⚠ Nicht konfiguriert${NC}"
        if [ "$ENVIRONMENT" = "HOST" ]; then
            ((WARNINGS++))
        fi
    fi
else
    echo -e "  - Git: ${RED}✗ Nicht installiert${NC}"
    if [ "$ENVIRONMENT" = "HOST" ]; then
        ((ERRORS++))
    fi
fi

# GitHub CLI
if command -v gh &> /dev/null && gh auth status &> /dev/null; then
    echo -e "  - GitHub CLI: ${GREEN}✓ Authentifiziert${NC}"
else
    echo -e "  - GitHub CLI: ${YELLOW}⚠ Nicht authentifiziert${NC}"
    if [ "$ENVIRONMENT" = "HOST" ]; then
        ((WARNINGS++))
    fi
fi

# Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    echo -e "  - Node.js: ${GREEN}✓ $NODE_VERSION${NC}"
else
    echo -e "  - Node.js: ${RED}✗ Nicht installiert${NC}"
    if [ "$ENVIRONMENT" = "HOST" ]; then
        ((ERRORS++))
    fi
fi

# 6. HOST-SPEZIFISCHE CHECKS
if [ "$ENVIRONMENT" = "HOST" ]; then
    echo ""
    echo "🏠 HOST-SPEZIFISCHE CHECKS:"
    
    # .env Datei
    if [ -f ".env" ]; then
        echo -e "  - .env: ${GREEN}✓ Vorhanden${NC}"
        if grep -q "change_me" .env 2>/dev/null; then
            echo -e "    ${YELLOW}⚠ Enthält noch Standardpasswörter!${NC}"
            ((WARNINGS++))
        fi
    else
        echo -e "  - .env: ${RED}✗ Fehlt${NC}"
        echo -e "    ${BLUE}→ cp .env.example .env && nano .env${NC}"
        ((ERRORS++))
    fi
    
    # Docker Image
    if docker images | grep -q "claude-code-docker"; then
        echo -e "  - Docker Image: ${GREEN}✓ Vorhanden${NC}"
    else
        echo -e "  - Docker Image: ${YELLOW}⚠ Noch nicht gebaut${NC}"
        echo -e "    ${BLUE}→ docker-compose build${NC}"
        ((WARNINGS++))
    fi
    
    # Container Status
    if docker ps | grep -q "claude-code-docker"; then
        echo -e "  - Container: ${GREEN}✓ Läuft${NC}"
    else
        echo -e "  - Container: Nicht gestartet"
    fi
fi

# 7. CONTAINER-SPEZIFISCHE CHECKS
if [ "$ENVIRONMENT" = "CONTAINER" ]; then
    echo ""
    echo "🐳 CONTAINER-SPEZIFISCHE CHECKS:"
    
    # MariaDB Verbindung
    if mysql -h mariadb -u claude -p"${MYSQL_PASSWORD:-}" -e "SELECT 1" claude_workspace &>/dev/null; then
        echo -e "  - MariaDB: ${GREEN}✓ Verbunden${NC}"
    else
        echo -e "  - MariaDB: ${YELLOW}⚠ Nicht erreichbar${NC}"
    fi
    
    # Email (msmtp)
    if command -v msmtp &> /dev/null; then
        echo -e "  - Email (msmtp): ${GREEN}✓ Installiert${NC}"
        if [ -n "$SMTP_HOST" ]; then
            echo -e "    SMTP-Host: $SMTP_HOST"
        else
            echo -e "    ${YELLOW}SMTP nicht konfiguriert${NC}"
        fi
    fi
fi

# 8. Hinweise basierend auf Umgebung
echo ""
echo "💡 HINWEISE:"
if [ "$ENVIRONMENT" = "CONTAINER" ]; then
    echo "  - Du bist im Container mit vollen Entwicklungsrechten"
    echo "  - Verwende Pfade unter ~/volumes/* für persistente Daten"
    echo "  - MCP-Server werden vom Host geerbt"
    echo "  - check-environment.sh für erneuten Check"
else
    echo "  - Du bist auf dem Host-System"
    echo "  - Verwende ./volumes/* für Zugriff auf Container-Daten"
    echo "  - MCP-Server mit 'claude mcp add' hinzufügen"
    echo "  - Container starten: docker-compose up -d"
fi

# 9. Zusammenfassung (nur auf Host)
if [ "$ENVIRONMENT" = "HOST" ]; then
    echo ""
    echo "===================================="
    echo "📊 ZUSAMMENFASSUNG"
    echo "===================================="
    
    if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}✅ Alles bereit!${NC}"
        echo ""
        echo "Nächste Schritte:"
        if ! docker images | grep -q "claude-code-docker"; then
            echo "1. docker-compose build"
        fi
        if ! docker ps | grep -q "claude-code-docker"; then
            echo "2. docker-compose up -d"
        fi
        echo "3. docker exec -it claude-code-docker bash"
    else
        if [ $ERRORS -gt 0 ]; then
            echo -e "${RED}❌ $ERRORS kritische Fehler${NC}"
        fi
        if [ $WARNINGS -gt 0 ]; then
            echo -e "${YELLOW}⚠ $WARNINGS Warnungen${NC}"
        fi
        echo ""
        echo "Bitte behebe die Probleme und führe das Skript erneut aus."
    fi
fi

echo "===================================="

# Optional: JSON-Output für maschinelle Verarbeitung
if [ "$1" = "--json" ]; then
    echo ""
    echo "JSON-OUTPUT:"
    cat << EOF
{
  "environment": "$ENVIRONMENT",
  "user": "$(whoami)",
  "home": "$HOME",
  "pwd": "$(pwd)",
  "volumes": {
    "repositories": $([ -d "/home/claude/volumes/repositories" ] || [ -d "./volumes/repositories" ] && echo "true" || echo "false"),
    "workspace": $([ -d "/home/claude/volumes/workspace" ] || [ -d "./volumes/workspace" ] && echo "true" || echo "false"),
    "obsidian": $([ -d "/home/claude/volumes/obsidian" ] || [ -d "./volumes/obsidian" ] && echo "true" || echo "false")
  },
  "access": {
    "ssh_agent": $([ -n "$SSH_AUTH_SOCK" ] && echo "true" || echo "false"),
    "docker": $([ -S /var/run/docker.sock ] && echo "true" || echo "false"),
    "git": $(command -v git &> /dev/null && echo "true" || echo "false"),
    "gh": $(command -v gh &> /dev/null && gh auth status &> /dev/null && echo "true" || echo "false"),
    "claude": $(command -v claude &> /dev/null && echo "true" || echo "false")
  }
}
EOF
fi

# Exit mit Fehlercode auf Host
if [ "$ENVIRONMENT" = "HOST" ]; then
    exit $ERRORS
fi