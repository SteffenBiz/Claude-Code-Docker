#!/bin/bash
set -e

echo "🚀 Starting Claude Docker Environment..."

# SSH-Agent verfügbar machen
if [ -S /ssh-agent ]; then
    export SSH_AUTH_SOCK=/ssh-agent
    echo "✓ SSH-Agent Socket verbunden"
    
    # Test ob SSH-Agent funktioniert
    if ssh-add -l >/dev/null 2>&1; then
        echo "✓ SSH-Agent funktioniert ($(ssh-add -l 2>/dev/null | wc -l) Keys geladen)"
    else
        echo "⚠ SSH-Agent verbunden aber keine Keys geladen"
    fi
else
    echo "⚠ SSH-Agent Socket nicht gefunden"
fi

# Claude Config Permissions korrigieren
if [ -d ~/.claude ]; then
    sudo chown -R claude:claude ~/.claude 2>/dev/null || true
    echo "✓ Claude Konfiguration verfügbar"
fi

# Git für SSH konfigurieren (falls nicht schon in .gitconfig)
if command -v git >/dev/null 2>&1; then
    git config --global url."git@github.com:".insteadOf "https://github.com/" 2>/dev/null || true
    echo "✓ Git für SSH konfiguriert"
fi

# Docker Socket Permissions
if [ -S /var/run/docker.sock ]; then
    sudo chmod 666 /var/run/docker.sock 2>/dev/null || true
    echo "✓ Docker Socket verfügbar"
fi

# MCP Server Pfade prüfen und konfigurieren
echo "📦 Installierte MCP Server:"
for server in filesystem github; do
    if [ -f "/usr/lib/node_modules/@modelcontextprotocol/server-$server/dist/index.js" ]; then
        echo "  ✓ $server"
    else
        echo "  ✗ $server nicht gefunden"
    fi
done

if [ -f "/usr/lib/node_modules/@benborla29/mcp-server-mysql/dist/index.js" ]; then
    echo "  ✓ mysql"
else
    echo "  ✗ mysql nicht gefunden"
fi

# MCP Server Status anzeigen
echo "🔧 MCP Server Status:"
if command -v claude >/dev/null 2>&1; then
    MCP_COUNT=$(claude mcp list 2>/dev/null | grep -v "No MCP servers" | wc -l)
    if [ $MCP_COUNT -gt 0 ]; then
        echo "  ✓ $MCP_COUNT MCP Server vom Host verfügbar"
    else
        echo "  ℹ️  Keine MCP Server konfiguriert"
        echo "  → MCP Server können auf dem Host mit 'claude mcp add' hinzugefügt werden"
    fi
else
    echo "  ✗ Claude CLI nicht verfügbar"
fi

# Bash Konfiguration
if [ ! -f ~/.bashrc.claude ]; then
    cat > ~/.bashrc.claude << 'EOF'
# SSH-Agent
export SSH_AUTH_SOCK=/ssh-agent

# Git Protocol
export GIT_PROTOCOL=ssh


# Git Branch im Prompt
parse_git_branch() {
    git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Farbiger Prompt
export PS1='\[\033[36m\]claude\[\033[m\]@\[\033[32m\]claude-code-docker\[\033[m\]:\[\033[33;1m\]\w\[\033[m\]\[\033[32m\]$(parse_git_branch)\[\033[m\]$ '

# PATH für lokale Scripts
export PATH="$PATH:/home/claude/volumes/workspace/scripts"
EOF
    echo "source ~/.bashrc.claude" >> ~/.bashrc
    echo "✓ Bash Konfiguration erstellt"
fi

# SMTP Konfiguration wenn Variablen gesetzt
if [ -n "$SMTP_HOST" ] && [ -n "$SMTP_USER" ]; then
    # msmtp Konfiguration erstellen
    cat > ~/.msmtprc << EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ~/.msmtp.log

account        default
host           $SMTP_HOST
port           $SMTP_PORT
from           $SMTP_FROM
user           $SMTP_USER
password       $SMTP_PASS
EOF
    chmod 600 ~/.msmtprc
    
    # Mail alias setzen
    echo "default: $SMTP_USER" > ~/.mailrc
    
    echo "✓ E-Mail-Versand konfiguriert (SMTP: $SMTP_HOST)"
else
    echo "⚠ E-Mail-Versand nicht konfiguriert (SMTP-Daten fehlen in .env)"
fi

echo ""
echo "🎉 Claude Docker Environment bereit!"
echo "📁 Arbeitsverzeichnis: $(pwd)"
echo ""

# Original Command ausführen
exec "$@"