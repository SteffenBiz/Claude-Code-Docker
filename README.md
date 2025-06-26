# Claude Code Docker - Multi-Profile Development Environment

Eine Docker-basierte Entwicklungsumgebung für Claude Code mit verschiedenen Entwicklungsprofilen. Bietet eine vollständig konfigurierte Arbeitsumgebung mit persistenten Volumes, Git-Integration, SSH-Agent-Weiterleitung und MariaDB.

## 🚀 Features

- **Multi-Profile Support**: Verschiedene Entwicklungsumgebungen (Web, Java, Python, Pentesting, Media)
- **Persistente Speicherung**: Alle Daten bleiben zwischen Container-Neustarts erhalten
- **SSH-Agent Integration**: Nahtlose Verwendung deiner SSH-Keys im Container
- **Git & GitHub Integration**: Vollständig konfiguriert mit deinen Host-Einstellungen
- **MCP Server Support**: Filesystem, GitHub und MariaDB MCP Server vorkonfiguriert
- **MariaDB Integration**: Eigene Datenbank-Instanz für Entwicklung
- **E-Mail Support**: SMTP-Konfiguration für E-Mail-Versand
- **Docker-in-Docker**: Zugriff auf Docker vom Container aus
- **Obsidian Wissensdatenbank**: Gemeinsames Gedächtnis zwischen Dir und Claude

## 📋 Voraussetzungen

- Docker und Docker Compose installiert
- SSH-Agent läuft (für Git/GitHub Zugriff)
- Git konfiguriert auf dem Host
- Claude Code CLI installiert auf dem Host
- Optional: GitHub CLI (`gh`) authentifiziert

## 🎯 Profile

### Web Development (`web`)
- **Tools**: Node.js 20, Deno, Bun, PHP 8.1, Ruby, Go, Rust
- **Frameworks**: Angular, Vue, React, Next.js, NestJS, Express
- **Build Tools**: Webpack, Vite, Parcel, Rollup
- **Package Manager**: npm, yarn, pnpm, Composer
- **Testing**: Jest, Mocha, Cypress

### Java Development (`java`)
- **JDK**: OpenJDK 11 & 17, GraalVM
- **Build Tools**: Maven, Gradle, Ant
- **Frameworks**: Spring Boot, Quarkus
- **Languages**: Java, Kotlin, Scala
- **Tools**: SDKMAN, IntelliJ IDEA (headless)

### Python Development (`python`)
- **Version Management**: pyenv, Conda/Mamba
- **Package Management**: pip, poetry, pipenv
- **Data Science**: NumPy, Pandas, SciPy, Scikit-learn, Jupyter
- **Deep Learning**: PyTorch, TensorFlow, Keras
- **Web Frameworks**: Django, Flask, FastAPI
- **Testing**: pytest, tox, unittest

### Penetration Testing (`pentest`)
- **Network**: Nmap, Masscan, Wireshark
- **Web**: Nikto, SQLMap, Burp Suite, OWASP ZAP
- **Exploitation**: Metasploit Framework
- **Password**: John, Hashcat, Hydra
- **OSINT**: theHarvester, Shodan
- ⚠️ **Hinweis**: Nur für autorisierte Sicherheitstests!

### Media Processing (`media`)
- **Video**: FFmpeg, OpenCV, MoviePy
- **Image**: ImageMagick, Pillow, GraphicsMagick
- **Audio**: Sox, Librosa
- **3D/Graphics**: Blender, OpenSCAD
- **OCR**: Tesseract
- **GPU Support**: Hardware-Beschleunigung für Video-Encoding

## 🔧 Installation

1. **Repository klonen**:
   ```bash
   git clone https://github.com/SteffenBiz/Claude-Code-Docker.git
   cd Claude-Code-Docker
   ```

2. **Umgebung prüfen**:
   ```bash
   ./check-environment.sh
   ```

3. **Umgebungsvariablen konfigurieren**:
   ```bash
   cp .env.example .env
   nano .env  # Passwörter ändern!
   ```

4. **MCP Server konfigurieren** (falls noch nicht geschehen):
   - Siehe `docs/MCP-SETUP.md` für detaillierte Anleitung
   - MCP Server werden auf dem HOST konfiguriert, nicht im Container

## 🚀 Verwendung

### Container starten

**WICHTIG**: Verwende immer das `start-claude.sh` Skript!

```bash
# Standard (Web-Profil)
./start-claude.sh

# Spezifisches Profil
./start-claude.sh python
./start-claude.sh java
./start-claude.sh pentest
./start-claude.sh media

# Mehrere Container (für parallele Arbeiten)
./start-claude.sh web 3

# Hilfe anzeigen
./start-claude.sh -h
```

### Container betreten

```bash
# Bei einzelnem Container
docker-compose exec claude-<profil> bash

# Beispiel für Web-Profil
docker-compose exec claude-web bash

# Bei mehreren Containern
docker ps | grep claude
docker exec -it <container-name> bash
```

### Claude im Container verwenden

**WICHTIG**: Im Container MUSS immer `--dangerously-skip-permissions` verwendet werden:

```bash
# Im Container
claude --dangerously-skip-permissions chat
claude --dangerously-skip-permissions "Analysiere diesen Code"

# Oder kurz mit Alias (cf = claude --dangerously-skip-permissions)
cf chat
cf "Erstelle eine Flask App"
```

### Container stoppen

```bash
docker-compose down

# Mit Entfernung verwaister Container
docker-compose down --remove-orphans
```

## 📁 Verzeichnisstruktur

```
claude-code-docker/
├── dockerfiles/           # Profile-spezifische Dockerfiles
│   ├── Dockerfile.base   # Basis-Image für alle Profile
│   ├── Dockerfile.web    # Web-Entwicklung
│   ├── Dockerfile.java   # Java-Entwicklung
│   ├── Dockerfile.python # Python-Entwicklung
│   ├── Dockerfile.pentest# Sicherheitstests
│   └── Dockerfile.media  # Media-Verarbeitung
├── volumes/              # Persistente Daten
│   ├── repositories/     # Git Repositories
│   ├── workspace/        # Arbeitsbereich
│   ├── obsidian/         # Wissensdatenbank (Deutsch)
│   ├── mariadb/          # Datenbank Backups
│   └── configs/          # Profil-spezifische Configs
│       ├── web/
│       ├── java/
│       ├── python/
│       ├── pentest/
│       ├── media/
│       └── shared/       # Gemeinsame Configs
├── scripts/              # Helper-Skripte
├── docs/                 # Dokumentation
├── CLAUDE.md            # Anweisungen für Claude
├── docker-compose.yml    # Docker Compose Konfiguration
├── docker-compose.multi.yml # Für mehrere Container
├── start-claude.sh      # Start-Skript
├── check-environment.sh # Umgebungs-Check
└── .env                 # Umgebungsvariablen
```

## 🔍 Umgebung prüfen

Im Container steht ein Check-Skript zur Verfügung:

```bash
# Im Container
/home/claude/check-environment.sh

# Für JSON-Output
/home/claude/check-environment.sh --json
```

## 🗄️ Datenbank

MariaDB läuft als separater Container:
- Host: `mariadb`
- Datenbank: `claude_workspace`
- User: `claude`
- Password: Siehe `.env`

## 📧 E-Mail-Versand

SMTP ist vorkonfiguriert. Im Container:

```bash
# Einfache E-Mail
echo "Test" | mail -s "Betreff" empfaenger@example.com

# Mit Python
python3 -c "
import yagmail
yag = yagmail.SMTP()
yag.send('empfaenger@example.com', 'Betreff', 'Nachricht')
"
```

## 🧩 MCP Server

Die folgenden MCP Server sind standardmäßig konfiguriert:
- **filesystem**: Zugriff auf Volume-Verzeichnisse
- **github**: GitHub API Integration
- **mariadb**: Datenbank-Zugriff

Details zur Konfiguration: `docs/MCP-SETUP.md`

## 📚 Obsidian Wissensdatenbank

Die Wissensdatenbank ist ein **gemeinsames Gedächtnis** zwischen dir und Claude:
- **NUR AUF DEUTSCH** - Alle Einträge in deutscher Sprache
- **Organische Struktur**, die mit den Projekten wächst
- **Qualität vor Quantität** - nur wichtige Informationen
- Gut vernetzt mit [[Wikilinks]]
- Respektiere bestehende Notizen

## 🛠️ Entwicklung

### Neues Profil hinzufügen

1. Erstelle `dockerfiles/Dockerfile.<profil>`
2. Füge Service in `docker-compose.yml` hinzu
3. Aktualisiere `start-claude.sh` mit dem neuen Profil
4. Erstelle `volumes/configs/<profil>/` Verzeichnis

### Profile anpassen

Die Dockerfiles in `dockerfiles/` können nach Bedarf angepasst werden. Nach Änderungen:

```bash
# Image neu bauen
docker-compose --profile <profil> build claude-<profil>

# Oder Base-Image neu bauen
docker build -t claude-code-docker:base -f dockerfiles/Dockerfile.base .
```

## 🐛 Fehlerbehebung

### Container startet nicht
- Prüfe ob Docker läuft: `docker ps`
- Prüfe die Logs: `docker-compose logs`
- Stelle sicher, dass die Ports frei sind

### SSH-Agent funktioniert nicht
- Prüfe ob SSH-Agent läuft: `echo $SSH_AUTH_SOCK`
- Starte SSH-Agent: `eval $(ssh-agent -s)`
- Füge Keys hinzu: `ssh-add`

### MCP Server nicht erreichbar
- Prüfe die Konfiguration auf dem Host: `~/.claude.json`
- MCP Server müssen auf dem HOST konfiguriert werden
- Siehe `docs/MCP-SETUP.md` für Details

### Build dauert zu lange
- Die vollständigen Profile enthalten viele Tools
- Für Tests gibt es ein minimales Profil: `docker-compose --profile test build`
- Images werden gecacht, zweiter Build ist schneller

## 🔒 Sicherheit

- Ändere ALLE Passwörter in `.env`
- SSH-Keys bleiben sicher auf dem Host
- `.env` niemals committen!
- Nur für Entwicklung, nicht für Produktion

## 📝 Lizenz

MIT License - siehe LICENSE Datei

## 🤝 Beitragen

Pull Requests sind willkommen! Für größere Änderungen bitte erst ein Issue erstellen.

## 📚 Weitere Dokumentation

- [MCP Server Setup](docs/MCP-SETUP.md)
- [Claude Anweisungen](CLAUDE.md)
- [Erweiterte Konfiguration](docs/ADVANCED.md)

---

🤖 Erstellt für autonomes Arbeiten mit Claude Code