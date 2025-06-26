FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Basis-System mit allen Tools die Claude nutzt
RUN apt-get update && apt-get install -y \
    # Basis
    curl wget git vim nano sudo \
    build-essential python3 python3-pip python3-venv \
    openssh-client \
    # Text-Processing & Search
    jq ripgrep fd-find tree htop \
    sed gawk grep \
    # System-Tools
    screen tmux watch \
    lsof net-tools iproute2 \
    cron \
    systemd systemd-sysv \
    # File-Tools
    rsync patch diffutils \
    file xxd \
    # Security
    openssl gnupg \
    # Archive
    tar gzip zip unzip \
    # Process Management
    procps psmisc \
    # Network Tools
    netcat dnsutils \
    # Development
    software-properties-common \
    # Email Tools
    msmtp msmtp-mta mailutils \
    # Database Clients
    mariadb-client postgresql-client redis-tools sqlite3 \
    # Web Development Languages
    php php-cli php-curl php-mbstring php-xml php-zip \
    php-mysql php-pgsql php-sqlite3 php-redis \
    php-gd php-imagick php-intl php-bcmath \
    php-json php-opcache php-readline \
    php-soap php-xdebug php-apcu \
    php-dom php-fileinfo php-iconv \
    php-pdo php-tokenizer php-ctype \
    php-fpm php-dev php-pear \
    composer \
    ruby ruby-dev \
    golang-go \
    # Media Processing
    imagemagick ffmpeg \
    # Web Servers (für lokale Tests)
    nginx apache2 \
    && rm -rf /var/lib/apt/lists/*

# Docker CLI für Docker-in-Docker Zugriff
RUN curl -fsSL https://get.docker.com | sh

# Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g yarn pnpm

# Rust (für moderne Build-Tools)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && mv /root/.cargo /opt/cargo \
    && ln -s /opt/cargo/bin/* /usr/local/bin/

# Bun (moderne JS Runtime)
RUN curl -fsSL https://bun.sh/install | bash \
    && mv /root/.bun /opt/bun \
    && ln -s /opt/bun/bin/bun /usr/local/bin/bun

# Deno (sichere JS/TS Runtime)
RUN curl -fsSL https://deno.land/x/install/install.sh | sh \
    && mv /root/.deno /opt/deno \
    && ln -s /opt/deno/bin/deno /usr/local/bin/deno

# GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    > /etc/apt/sources.list.d/github-cli.list \
    && apt-get update && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Claude Code und MCP Server global installieren
RUN npm install -g \
    @anthropic-ai/claude-code \
    @modelcontextprotocol/server-filesystem \
    @modelcontextprotocol/server-github \
    @benborla29/mcp-server-mysql

# Globale npm Tools für Webentwicklung
RUN npm install -g \
    # Build Tools
    webpack webpack-cli vite parcel rollup \
    # Framework CLIs
    @angular/cli @vue/cli create-react-app \
    @nestjs/cli express-generator \
    # Testing
    jest mocha cypress \
    # Linting & Formatting
    eslint prettier \
    # TypeScript
    typescript ts-node tsx \
    # Process Management
    pm2 nodemon \
    # Utilities
    npm-check-updates serve http-server \
    # API Development
    json-server

# Python Tools für Webentwicklung
RUN pip3 install --upgrade pip && \
    pip3 install --ignore-installed \
    # Code Quality
    black flake8 mypy pylint \
    # Testing
    pytest pytest-cov pytest-asyncio \
    # Web Frameworks
    django flask fastapi uvicorn \
    # HTTP & API
    requests httpx aiohttp \
    # Database
    sqlalchemy pymongo redis psycopg2-binary \
    # Data Processing
    pandas numpy beautifulsoup4 lxml \
    # Utilities
    python-dotenv virtualenv pipenv poetry \
    # Email libraries
    yagmail emails \
    # Task Runners
    celery \
    # Template Engines
    jinja2

# Claude User mit sudo und docker Gruppe
RUN useradd -m -s /bin/bash claude \
    && usermod -aG sudo,docker claude \
    && echo 'claude ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Arbeitsverzeichnisse
RUN mkdir -p /home/claude/volumes/repositories /home/claude/volumes/workspace /home/claude/volumes/obsidian \
    && chown -R claude:claude /home/claude/volumes

# SSH Verzeichnis vorbereiten
RUN mkdir -p /home/claude/.ssh \
    && chown -R claude:claude /home/claude/.ssh \
    && chmod 700 /home/claude/.ssh

# Scripts kopieren
COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER claude
WORKDIR /home/claude

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]