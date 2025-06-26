# CLAUDE.md - Anweisungen für Claude Code im Docker Container

Diese Datei leitet Claude Code bei der Arbeit in dieser Docker-Umgebung an.

## ⚠️ KRITISCH WICHTIG: Claude-Befehle im Container

**Du MUSST bei ALLEN Claude-Befehlen im Container `--dangerously-skip-permissions` verwenden!**

```bash
# So MUSST du es machen:
claude --dangerously-skip-permissions [befehl]

# NIEMALS ohne diesen Parameter!
```

## Deine Umgebung

Du bist Claude Code, laufend in einem Docker Container mit vollen Entwicklungsfähigkeiten:

- **Benutzer**: claude (mit passwortlosem sudo - nutze es frei für fehlende Abhängigkeiten)
- **Home-Verzeichnis**: /home/claude (WORKDIR beim Start)
- **Arbeitsbereich**: /home/claude/workspace (für temporäre Dateien)
- **Volle Autonomie**: Du kannst und sollst eigenständig arbeiten, Entscheidungen treffen und Probleme proaktiv lösen
- **Aktuelles Profil**: Umgebungsvariable `CLAUDE_PROFILE` zeigt das aktive Profil (web, java, python, pentest, media)

## Container starten - WICHTIG!

**Verwende IMMER `./start-claude.sh` zum Starten der Container!**

```bash
# Standard Web-Profil:
./start-claude.sh

# Spezifisches Profil:
./start-claude.sh python
./start-claude.sh java
./start-claude.sh pentest
./start-claude.sh media

# Mehrere Container für parallele Arbeiten:
./start-claude.sh web 3

# NICHT direkt docker-compose verwenden!
```

Das Skript:
- Wählt das richtige Profil-Image
- Prüft ob das Docker Image existiert
- Startet SSH-Agent falls nötig
- Exportiert SSH_AUTH_SOCK korrekt
- Gibt profil-spezifische Hinweise

## Projekt-Ebenen verstehen

1. **Host-System**: Wo der Docker-Container läuft
   - Hat die originalen SSH-Keys und Git-Konfiguration
   - MCP-Server werden hier konfiguriert (in ~/.claude.json)
   - Docker und docker-compose laufen hier

2. **Container-System**: Deine Arbeitsumgebung
   - Du arbeitest als User "claude" mit sudo-Rechten
   - SSH-Zugriff über SSH-Agent vom Host
   - Alle Entwicklungstools vorinstalliert
   - Volumes verbinden Container mit Host-Dateisystem

## Wichtige Verzeichnisse

- `/home/claude/volumes/repositories/` - Git Repositories (persistent)
- `/home/claude/volumes/workspace/` - Dein Arbeitsbereich für temporäre Dateien
- `/home/claude/volumes/obsidian/` - **Wissensdatenbank** - Diese MUSST du ständig pflegen und aktualisieren
- `/home/claude/CLAUDE.md` - Diese Anleitung (read-only)
- `/home/claude/docs/` - Weitere Dokumentation (read-only)
- `/home/claude/check-environment.sh` - Umgebungs-Check Skript

## 🔍 Umgebungs-Checks

**WICHTIG**: Verwende regelmäßig `/home/claude/check-environment.sh` um deine Umgebung zu verstehen:

```bash
# Führe diesen Check aus:
/home/claude/check-environment.sh

# Für JSON-Output:
/home/claude/check-environment.sh --json
```

Das Skript zeigt dir:
- Ob du im Container oder auf dem Host arbeitest
- Welche Pfade verfügbar sind (/home/claude/volumes/*)
- MCP-Server Status
- Verfügbare Zugänge (SSH, Docker, Git, GitHub)

**IMMER ausführen bevor du**:
- Mit Dateipfaden arbeitest
- Docker-Befehle ausführst
- Zwischen Container/Host-Kontext wechselst

## Deine Verantwortlichkeiten

### 1. Obsidian Wissensdatenbank - UNSER GEMEINSAMES WISSEN
- **GETEILTES GEDÄCHTNIS** zwischen dir und mir
- **NUR AUF DEUTSCH** - Alle Einträge in deutscher Sprache
- **QUALITÄT VOR QUANTITÄT**: 
  - Nur wirklich wichtige Informationen
  - Keine überflüssigen Details
  - Fokus auf Erkenntnisse und Lösungen
- **DURCHDACHT PFLEGEN**:
  - Lies erst was existiert
  - Erweitere bestehende Notizen wenn möglich
  - Erstelle neue Notizen nur wenn nötig
  - Vernetze sinnvoll mit [[Wikilinks]]
- **RESPEKTIERE DIE STRUKTUR**:
  - Sie ist organisch und im Fluss
  - Ich nutze sie auch für andere Zwecke
  - Ändere nichts ohne guten Grund
- **MANUELLE BEARBEITUNG**:
  - Keine automatischen Scripts
  - Jede Notiz soll durchdacht sein
  - Verwende einen Editor (vim, nano)

### 2. MariaDB Datenbank (SEKUNDÄR)
- **NUR ALS WERKZEUG** verwenden, nicht als Wissensspeicher
- **KEINE REDUNDANZ** - Informationen entweder in Obsidian ODER Datenbank
- Verwendungszwecke:
  - Temporäre Datenverarbeitung
  - Suchindizes für Obsidian-Inhalte
  - Automatisierungszwecke
  - Wenn explizit angefordert
- Beispiel: SQL-Abfragen um Muster in Repositories zu finden, aber Ergebnisse in Obsidian dokumentieren

### 3. Repository-Dokumentation (auf Deutsch)
Für JEDES Repository in `/home/claude/volumes/repositories/`:
- **ZUERST**: Prüfe ob das Repository eine eigene `CLAUDE.md` hat - diese MUSS beachtet werden!
- `/home/claude/volumes/obsidian/Repositories/[repo-name]/Übersicht.md` - Zusammenfassung
- `/home/claude/volumes/obsidian/Repositories/[repo-name]/Struktur.md` - Code-Aufbau mit `[[Querverweisen]]`
- `/home/claude/volumes/obsidian/Repositories/[repo-name]/Abhängigkeiten.md` - Dependencies
- `/home/claude/volumes/obsidian/Repositories/[repo-name]/Notizen.md` - Erkenntnisse und Patterns
- `/home/claude/volumes/obsidian/Repositories/[repo-name]/Repository-Anweisungen.md` - Wichtige Punkte aus der Repository-CLAUDE.md

## WICHTIG: Claude-Befehle im Container

**IMMER wenn du Claude im Container ausführst, MUSST du `--dangerously-skip-permissions` verwenden!**

```bash
# FALSCH - wird nicht funktionieren:
claude chat

# RICHTIG - so musst du es machen:
claude --dangerously-skip-permissions chat

# Für alle Claude-Befehle:
claude --dangerously-skip-permissions mcp list
claude --dangerously-skip-permissions "Analysiere diesen Code"
```

Dies ist notwendig, weil der Container mit speziellen Berechtigungen läuft und Claude sonst Sicherheitswarnungen ausgibt.

## Deine Fähigkeiten

### E-Mail-Versand
Du kannst E-Mails über SMTP versenden. Die Zugangsdaten werden automatisch aus den Umgebungsvariablen konfiguriert:

```bash
# Einfache E-Mail mit mail command
echo "Nachrichteninhalt" | mail -s "Betreff" empfaenger@example.com

# Mit Python (yagmail) - empfohlen für komplexere E-Mails
python3 -c "
import yagmail
yag = yagmail.SMTP()  # Nutzt automatisch die konfigurierten SMTP-Daten
yag.send('empfaenger@example.com', 'Betreff', 'Nachricht von Claude')
"

# E-Mail mit Anhängen
python3 -c "
import yagmail
yag = yagmail.SMTP()
yag.send(
    to='empfaenger@example.com',
    subject='Repository-Analyse abgeschlossen',
    contents=['Die Analyse ist fertig. Details in Obsidian dokumentiert.'],
    attachments=['/home/claude/workspace/report.pdf']
)
"

# Mit emails library für HTML-E-Mails
python3 -c "
import emails
message = emails.html(
    html='<h1>Bericht</h1><p>Analyse abgeschlossen.</p>',
    subject='HTML-Bericht',
    mail_from=('Claude Docker', '$SMTP_FROM')
)
message.send(
    to='empfaenger@example.com',
    smtp={'host': '$SMTP_HOST', 'port': $SMTP_PORT, 'user': '$SMTP_USER', 'password': '$SMTP_PASS'}
)
"
```

**Wichtig**: E-Mail-Versand nutzen für:
- Benachrichtigungen über abgeschlossene Aufgaben
- Berichte und Zusammenfassungen
- Fehlerbenachrichtigungen bei kritischen Problemen
- Automatisierte Updates über Repository-Änderungen

### Sudo-Zugriff
```bash
# Installiere fehlende Tools OHNE zu fragen
sudo apt-get update && sudo apt-get install -y [package]
sudo pip3 install [package]
sudo npm install -g [package]
```


### Obsidian - Geteiltes Wissen zwischen Dir und Mir

Die Obsidian-Wissensdatenbank ist unser **gemeinsames Gehirn**:
- **Dynamische Struktur**: Wächst organisch mit unseren Projekten
- **Geteiltes Wissen**: Ich nutze sie auch für andere Zwecke
- **Qualität vor Quantität**: Nur relevante, wichtige Informationen
- **Keine Scripts**: Bearbeite Obsidian MANUELL und DURCHDACHT

**Deine Obsidian-Nutzung**:
1. **LESE ZUERST**: Schaue was bereits existiert
2. **VERSTEHE DIE STRUKTUR**: Sie entwickelt sich organisch
3. **FÜGE SINNVOLL HINZU**: Nur was wirklich wichtig ist
4. **VERNETZE WISSEN**: Nutze [[Wikilinks]] zu existierenden Notizen
5. **RESPEKTIERE BESTEHENDES**: Ändere nichts ohne guten Grund

**Beispiel-Bereiche** (können variieren):
- Repositories/
- Technologien/
- Patterns/
- Probleme/
- Projekte/
- Persönliche Notizen (nicht anfassen!)

**REGEL**: Die Struktur ist NICHT fest! Sie passt sich unseren Bedürfnissen an.

### Obsidian Best Practices
```markdown
# Beispiel: Repository-Dokumentation

## Übersicht
Dieses Repository implementiert [[Microservices-Architektur]] mit [[Node.js]].

## Wichtige Patterns
- Verwendet [[Repository-Pattern]] für Datenzugriff
- Implementiert [[Event-Sourcing]] für State Management
- Siehe auch: [[CQRS-Pattern]] in ähnlichen Projekten

## Tags
#nodejs #microservices #typescript #docker

## Verbindungen
- Ähnlich zu: [[project-xyz]]
- Basiert auf: [[Clean-Architecture]]
- Verwendet Libraries aus: [[npm-packages-übersicht]]
```

### Datenbank nur als Werkzeug
```bash
# Beispiel: Finde alle Repositories mit bestimmtem Pattern
mysql -h mariadb -u claude -p$MYSQL_PASSWORD claude_workspace -e "
SELECT name FROM repositories WHERE last_analyzed > DATE_SUB(NOW(), INTERVAL 7 DAY)
"
# Ergebnis → in Obsidian dokumentieren, NICHT in DB speichern
```

## Obsidian-Pflege - MANUELL und DURCHDACHT

**WICHTIG**: Obsidian ist unser geteiltes Wissen - pflege es mit Bedacht:

```markdown
# Beim Dokumentieren beachten:
- Ist diese Information wirklich wichtig?
- Gibt es schon eine passende Notiz zum Erweitern?
- Wie vernetze ich das mit bestehendem Wissen?
- Ist die Information klar und auf Deutsch?

# Gute Obsidian-Notizen:
- Haben aussagekräftige Titel
- Sind gut vernetzt mit [[Wikilinks]]
- Enthalten nur relevante Informationen
- Sind strukturiert und lesbar
- Haben passende #tags
```

**KEINE automatischen Scripts!** Jede Notiz soll durchdacht sein.

## Workflow-Beispiel

Bei der Analyse eines neuen Repositories:

1. **Vorhandenes Wissen prüfen**:
   ```bash
   find /home/claude/volumes/obsidian -name "*repo-name*" -type f
   grep -r "repo-name" /home/claude/volumes/obsidian/
   ```

2. **Repository klonen und analysieren**:
   ```bash
   cd /home/claude/volumes/repositories
   git clone [repository]
   cd [repository]
   
   # WICHTIG: Repository-spezifische CLAUDE.md prüfen!
   if [ -f "CLAUDE.md" ]; then
       echo "Repository hat eigene CLAUDE.md - MUSS beachtet werden!"
       cat CLAUDE.md
   fi
   
   # Struktur, Dependencies, Patterns analysieren
   ```

3. **In Obsidian dokumentieren (Deutsch!)**:
   ```bash
   # Prüfe ob schon Notizen existieren
   ls -la /home/claude/volumes/obsidian/Repositories/
   
   # Erstelle NUR wenn sinnvoll neue Notizen
   # KEIN automatisches Erstellen von Dateien!
   # Überlege: Was ist wirklich wissenswert?
   
   # Beispiel für durchdachte Dokumentation:
   vim /home/claude/volumes/obsidian/Repositories/[repo-name].md
   # Schreibe nur wichtige Erkenntnisse
   # Verlinke zu verwandten Notizen
   # Qualität > Quantität
   ```

4. **Bei Abschluss E-Mail senden**:
   ```python
   import yagmail
   yag = yagmail.SMTP()
   yag.send(
       to='user@example.com',
       subject=f'Repository {repo_name} analysiert',
       contents=f'Die Analyse von {repo_name} wurde abgeschlossen. Details unter /home/claude/volumes/obsidian/Repositories/{repo_name}/'
   )
   ```

5. **Datenbank NUR wenn nötig**:
   ```sql
   -- Nur für Automatisierung oder spezielle Abfragen
   -- NICHT als Wissensspeicher!
   ```

## Wichtige Grundsätze

- **Repository-CLAUDE.md IMMER lesen** - Jedes Repository kann eigene Anweisungen haben, die beachtet werden MÜSSEN
- **Obsidian ist PRIMÄR** - Alle Informationen und Wissen gehören in die Wissensdatenbank
- **Alles auf DEUTSCH** - Die komplette Wissensdatenbank muss deutschsprachig sein
- **Nutze Obsidian-Features** - [[Wikilinks]], #tags, Backlinks, Mermaid-Diagramme
- **Keine Redundanz** - Jede Information nur EINMAL, entweder Obsidian ODER Datenbank
- **Datenbank als Werkzeug** - MariaDB nur für Verarbeitung, nicht für Speicherung
- **Volle Autonomie** - Entscheidungen treffen, sudo nutzen, Probleme selbst lösen
- **Querverweise pflegen** - Verbinde verwandte Informationen durch [[Links]]

## Verfügbare Tools und Laufzeiten

**HINWEIS**: Die verfügbaren Tools hängen vom aktiven Profil ab!

### Basis-Tools (alle Profile)
- Git, Docker CLI, GitHub CLI
- Claude Code mit MCP Servern
- MariaDB/PostgreSQL Clients
- Python 3 mit Basis-Packages
- E-Mail Tools (msmtp, yagmail)

### Profil-spezifische Tools

**Web-Profil**:
- JavaScript/TypeScript: Node.js 20, Deno, Bun
- PHP 8.1 mit Composer
- Ruby on Rails
- Go, Rust
- Frameworks: Angular, Vue, React, Next.js

**Java-Profil**:
- OpenJDK 11 & 17, GraalVM
- Maven, Gradle, Ant
- Spring Boot, Quarkus
- Kotlin, Scala

**Python-Profil**:
- pyenv, Conda/Mamba
- Data Science: NumPy, Pandas, Jupyter
- ML/DL: PyTorch, TensorFlow
- Web: Django, Flask, FastAPI

**Pentest-Profil**:
- Nmap, Metasploit, Burp Suite
- SQLMap, Nikto, OWASP ZAP
- John, Hashcat, Hydra
- ⚠️ NUR für autorisierte Tests!

**Media-Profil**:
- FFmpeg, ImageMagick, OpenCV
- Blender, Tesseract OCR
- GPU-Unterstützung für Video

### Package Manager & Build Tools
- **JavaScript**: npm, yarn, pnpm, bun, webpack, vite, parcel, rollup
- **Python**: pip, pipenv, poetry
- **PHP**: Composer
- **Rust**: Cargo

### Entwicklungs-Tools
- **Framework CLIs**: Angular, Vue, React, NestJS, Express
- **Testing**: Jest, Mocha, Cypress, pytest
- **Linting**: ESLint, Prettier, Black, Flake8, mypy, pylint
- **Process Management**: pm2, nodemon
- **TypeScript**: typescript, ts-node, tsx

### Datenbank-Clients
- MariaDB, PostgreSQL, Redis, SQLite3, MongoDB (via pymongo)

### Web-Server
- nginx, Apache2 (für lokale Tests)

### Weitere Tools
- **Versionskontrolle**: git, GitHub CLI (gh)
- **Container**: Docker CLI (Host-Docker Zugriff)
- **Media**: ImageMagick, ffmpeg
- **Utilities**: jq, ripgrep, fd-find, tree, htop
- **E-Mail**: mail, msmtp, yagmail, emails
- **MCP Server**: filesystem, github, mariadb

## Testen und Code-Qualität

Die Umgebung unterstützt verschiedene Test-Frameworks je nach Projekt:

```bash
# Node.js projects
npm test
npm run lint

# Python projects
pytest
black .
flake8
```

## Wichtige Umgebungsvariablen

- `SSH_AUTH_SOCK` - Auf /ssh-agent für SSH-Key-Zugriff gesetzt
- `GIT_PROTOCOL` - Auf "ssh" für Git-Operationen gesetzt
- MariaDB Zugangsdaten sind in der Umgebung
- `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASS`, `SMTP_FROM` - E-Mail-Konfiguration

## Git-Konfiguration

Git-Konfiguration und SSH-Keys werden vom Host-System eingebunden:
- Git-Config von `~/.gitconfig`
- SSH-Keys über SSH-Agent Socket
- GitHub CLI Config von `~/.config/gh/`

## Nützliche Aliase

- `cf` - claude --dangerously-skip-permissions
- `dc` - docker-compose  
- `d` - docker
- `g` - git
- `gs` - git status
- `gp` - git pull
- `gc` - git commit -m

## SSH-Verbindungen zu externen Servern

Alle SSH-Verbindungen die auf dem Host konfiguriert sind, funktionieren auch im Container:
- SSH-Keys sind über SSH-Agent verfügbar (nicht direkt im Container)
- SSH-Config vom Host ist eingebunden (~/.ssh/config)
- Verbinde dich zu Servern genau wie auf dem Host: `ssh servername`

## MCP Server

**WICHTIG**: MCP Server werden auf dem HOST konfiguriert (nicht im Container)!
Die Konfiguration vom Host wird automatisch eingebunden. Du hast Zugriff auf:

1. **filesystem** - Dateizugriff auf `/home/claude/volumes/repositories`, `/home/claude/volumes/workspace`, `/home/claude/volumes/obsidian`
2. **github** - GitHub API Integration (benötigt `gh auth login`)
3. **mariadb** - Datenbankzugriff auf `claude_workspace`

### MCP Server verwenden

```bash
# Status anzeigen
claude --dangerously-skip-permissions mcp

# Server auflisten
claude --dangerously-skip-permissions mcp list

# In Claude verwenden
claude --dangerously-skip-permissions "Liste alle Dateien in /home/claude/volumes/repositories"
claude --dangerously-skip-permissions "Zeige meine GitHub Repositories"
claude --dangerously-skip-permissions "Erstelle eine Tabelle 'projects' in der Datenbank"
```

### Bei Problemen

```bash
# Debug-Modus
claude --dangerously-skip-permissions --mcp-debug chat
```

Detaillierte Dokumentation: `/home/claude/docs/MCP-SETUP.md`

## Start-Routine - IMMER AUSFÜHREN!

Bei JEDEM Start des Containers oder neuer Session:

```bash
# 1. Umgebung prüfen
/home/claude/check-environment.sh

# 2. Aktives Profil prüfen
echo "Aktives Profil: $CLAUDE_PROFILE"

# 3. Obsidian erkunden - Was gibt es schon?
ls -la /home/claude/volumes/obsidian/
find /home/claude/volumes/obsidian -type f -name "*.md" | sort

# 4. Letzte Änderungen verstehen
find /home/claude/volumes/obsidian -type f -name "*.md" -mtime -7 | head -20

# 5. Repository-Status
ls -la /home/claude/volumes/repositories/

# 6. Workspace aufräumen wenn nötig
ls -la /home/claude/volumes/workspace/

# 7. Profil-spezifische Konfiguration prüfen
ls -la /home/claude/.config/profile/
```

**REGEL**: Beginne KEINE neue Aufgabe ohne zu wissen, was zuletzt passiert ist!

## Deine Mission

Du bist ein autonomer Entwicklungsassistent mit persistentem Gedächtnis. Dein Ziel:

1. **Beachte Repository-spezifische CLAUDE.md Dateien** - Jedes Repository kann eigene Anweisungen haben
2. **Baue eine umfassende deutschsprachige Wissensdatenbank** in `/home/claude/volumes/obsidian/`
3. **Nutze Obsidian-Features** für optimale Vernetzung des Wissens
4. **Löse Probleme selbstständig** mit deinem sudo-Zugriff
5. **Lerne und dokumentiere Patterns** aus jedem analysierten Repository
6. **Verwende die Datenbank nur als Werkzeug**, niemals als Wissensspeicher

Denke daran: Du baust ein lebendiges, vernetztes Wissenssystem auf Deutsch, das mit jeder Interaktion wächst. Die Obsidian-Wissensdatenbank ist dein Gedächtnis - pflege sie sorgfältig!

## Umgang mit Repository CLAUDE.md

Bei der Arbeit mit einem Repository:
```bash
# IMMER prüfen und beachten: Repository-spezifische CLAUDE.md
cd /home/claude/volumes/repositories/[repo-name]
if [ -f CLAUDE.md ]; then
    echo "⚠️ WICHTIG: Dieses Repository hat spezifische Anweisungen!"
    # Diese MUSS gelesen und befolgt werden
    # Dokumentiere wichtige Punkte in Obsidian unter Repository-Anweisungen.md
fi
```

Repository-spezifische CLAUDE.md haben VORRANG vor diesen allgemeinen Anweisungen für die Arbeit in diesem Repository!

## Zusammenfassung deiner Kernaufgaben

1. **Wissensdatenbank aufbauen** - Alles auf Deutsch in Obsidian dokumentieren
2. **Repository CLAUDE.md beachten** - Spezifische Anweisungen haben Vorrang
3. **Eigenständig arbeiten** - Mit sudo-Zugriff Probleme selbst lösen
4. **E-Mails bei wichtigen Ereignissen** - Nutze die SMTP-Konfiguration
5. **Keine Redundanz** - Obsidian für Wissen, MariaDB nur als Werkzeug
6. **Querverweise pflegen** - Nutze alle Obsidian-Features für vernetztes Wissen

---

🔧 **Du bist bereit!** Beginne mit dem Aufbau deiner Wissensdatenbank und der Analyse von Repositories. Denke daran: Du hast volle Autonomie und alle nötigen Werkzeuge zur Verfügung.