#!/bin/bash

# Farben
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Standard-Profil
DEFAULT_PROFILE="web"

# Hilfe anzeigen
show_help() {
    echo "Claude Code Docker Starter"
    echo ""
    echo "Verwendung:"
    echo "  ./start-claude.sh [PROFIL] [ANZAHL]"
    echo ""
    echo "Profile:"
    echo "  web      - Web-Entwicklung (Node.js, PHP, Ruby, Go, Rust)"
    echo "  java     - Java-Entwicklung (JDK, Maven, Gradle, Spring Boot)"
    echo "  python   - Python-Entwicklung (Data Science, ML, Web)"
    echo "  pentest  - Penetration Testing (Sicherheitstools)"
    echo "  media    - Media Processing (Bild, Video, Audio)"
    echo ""
    echo "Beispiele:"
    echo "  ./start-claude.sh           # Startet Web-Profil"
    echo "  ./start-claude.sh python    # Startet Python-Profil"
    echo "  ./start-claude.sh web 3     # Startet 3 Web-Container"
    echo ""
}

# Parameter parsen
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Profil bestimmen
PROFILE="${1:-$DEFAULT_PROFILE}"
COUNT="${2:-1}"

# Wenn erstes Argument eine Zahl ist, verwende Default-Profil
if [[ "$1" =~ ^[0-9]+$ ]]; then
    PROFILE="$DEFAULT_PROFILE"
    COUNT="$1"
fi

# Profil validieren
VALID_PROFILES=("web" "java" "python" "pentest" "media")
if [[ ! " ${VALID_PROFILES[@]} " =~ " ${PROFILE} " ]]; then
    echo -e "${RED}❌ Ungültiges Profil: $PROFILE${NC}"
    echo -e "${YELLOW}Verfügbare Profile: ${VALID_PROFILES[*]}${NC}"
    exit 1
fi

# Export für Docker Compose
export CLAUDE_PROFILE="$PROFILE"

# Image Name mit Profil
IMAGE_NAME="claude-code-docker:$PROFILE"

# Prüfe ob Basis-Image existiert
if ! docker images | grep -q "claude-code-docker.*base"; then
    echo -e "${YELLOW}⚠️  Basis-Image noch nicht gebaut!${NC}"
    echo "Baue Basis-Image..."
    docker build -t claude-code-docker:base -f dockerfiles/Dockerfile.base .
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Fehler beim Bauen des Basis-Images!${NC}"
        exit 1
    fi
fi

# Prüfe ob Profil-Image existiert
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo -e "${YELLOW}⚠️  $PROFILE-Image noch nicht gebaut!${NC}"
    echo "Baue $PROFILE-Image..."
    docker-compose --profile $PROFILE build claude-$PROFILE
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Fehler beim Bauen des $PROFILE-Images!${NC}"
        exit 1
    fi
fi

# SSH-Agent prüfen
if [ -z "$SSH_AUTH_SOCK" ]; then
    echo "Starte SSH-Agent..."
    eval $(ssh-agent -s)
    ssh-add ~/.ssh/id_* 2>/dev/null
fi

# Export für Docker Compose
export SSH_AUTH_SOCK

# Profil-spezifische Konfigurationsverzeichnisse erstellen
mkdir -p volumes/configs/{web,java,python,pentest,media,shared}

# Container starten
if [ "$COUNT" -eq 1 ]; then
    # Einzelner Container mit festem Namen
    docker-compose --profile $PROFILE up -d
    echo ""
    echo -e "${GREEN}✅ Claude Container gestartet!${NC}"
    echo -e "${BLUE}📌 Profil: $PROFILE${NC}"
    echo -e "${BLUE}📌 Container Name: claude-code-docker-$PROFILE${NC}"
    echo ""
    echo "Container betreten mit:"
    echo "  docker-compose exec claude-$PROFILE bash"
    echo ""
    
    # Profil-spezifische Hinweise
    case "$PROFILE" in
        pentest)
            echo -e "${YELLOW}⚠️  SICHERHEITSHINWEIS:${NC}"
            echo "Pentesting-Tools nur für autorisierte Tests verwenden!"
            echo "Immer schriftliche Genehmigung einholen!"
            ;;
        media)
            echo -e "${BLUE}💡 Media-Tools verfügbar:${NC}"
            echo "ffmpeg, imagemagick, opencv, etc."
            echo "GPU-Beschleunigung aktiviert für Video-Encoding"
            ;;
        python)
            echo -e "${BLUE}💡 Python-Umgebungen:${NC}"
            echo "pyenv, conda/mamba, poetry, pipenv verfügbar"
            ;;
        java)
            echo -e "${BLUE}💡 Java-Versionen:${NC}"
            echo "OpenJDK 11 & 17, GraalVM verfügbar"
            echo "SDKMAN für Version Management"
            ;;
        web)
            echo -e "${BLUE}💡 Web-Stacks:${NC}"
            echo "Node.js, Deno, Bun, PHP, Ruby, Go, Rust"
            ;;
    esac
else
    # Mehrere Container
    docker-compose -f docker-compose.multi.yml up -d --scale claude=$COUNT
    echo ""
    echo -e "${GREEN}✅ $COUNT Claude Container gestartet!${NC}"
    echo -e "${BLUE}📌 Profil: $PROFILE${NC}"
    echo ""
    echo "Container auflisten mit:"
    echo "  docker ps | grep claude"
    echo ""
    echo "Spezifischen Container betreten mit:"
    echo "  docker exec -it <container-name> bash"
fi

echo ""
echo -e "${BLUE}📌 SSH-Agent Socket: $SSH_AUTH_SOCK${NC}"
echo ""
echo "Container stoppen mit:"
echo "  docker-compose down"
echo ""
echo "Profil wechseln:"
echo "  docker-compose down"
echo "  ./start-claude.sh <anderes-profil>"