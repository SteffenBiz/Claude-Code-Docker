#!/bin/bash

# Anzahl der Container (Standard: 1)
COUNT=${1:-1}

# Farben
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Prüfe ob Docker Image existiert
if ! docker images | grep -q "claude-code-docker"; then
    echo -e "${RED}❌ Docker Image noch nicht gebaut!${NC}"
    echo "Bitte erst ausführen: docker-compose build"
    exit 1
fi

# SSH-Agent prüfen
if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Starte SSH-Agent..."
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_* 2>/dev/null
fi

# Export für Docker Compose
export SSH_AUTH_SOCK

if [ "$COUNT" -eq 1 ]; then
    # Einzelner Container mit festem Namen
    docker-compose up -d
    echo ""
    echo "✅ Claude Container gestartet!"
    echo "📌 Container Name: claude-code-docker"
    echo ""
    echo "Container betreten mit:"
    echo "  docker-compose exec claude bash"
else
    # Mehrere Container
    docker-compose -f docker-compose.multi.yml up -d --scale claude=$COUNT
    echo ""
    echo "✅ $COUNT Claude Container gestartet!"
    echo ""
    echo "Container auflisten mit:"
    echo "  docker ps | grep claude"
    echo ""
    echo "Spezifischen Container betreten mit:"
    echo "  docker exec -it <container-name> bash"
fi

echo ""
echo "📌 SSH-Agent Socket: $SSH_AUTH_SOCK"
echo ""
echo "Container stoppen mit:"
echo "  docker-compose down"
