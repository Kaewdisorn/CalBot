# ---------------------------------------------------------
# STAGE 1 — Build Flutter Web
# ---------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

WORKDIR /app/frontend

# Copy Flutter project
COPY frontend/ .

RUN flutter clean

RUN flutter pub get

# Enable Flutter web
RUN flutter config --enable-web

# Build release
RUN flutter build web --release

# Add cache-busting meta tags to index.html
RUN sed -i '/<head>/a \  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">\n  <meta http-equiv="Pragma" content="no-cache">\n  <meta http-equiv="Expires" content="0">' /app/frontend/build/web/index.html


# ---------------------------------------------------------
# STAGE 2 — Build Node Backend
# ---------------------------------------------------------
FROM node:20-alpine AS node-builder

WORKDIR /app/backend/node-server

# Copy only package files first (better caching)
COPY backend/node-server/package*.json ./

RUN npm install --production

# Copy backend source
COPY backend/node-server/src ./src


# ---------------------------------------------------------
# STAGE 3 — Discord Bot (Python)
# ---------------------------------------------------------
FROM python:3.13-slim AS bot-builder

WORKDIR /app/backend/bot-server

# Copy requirements first (better caching)
COPY backend/bot-server/requirements.in ./

# Install from .in file (simpler deps, no version lock issues)
RUN pip install --no-cache-dir discord.py openai python-dotenv

# Copy bot source
COPY backend/bot-server/ ./


# ---------------------------------------------------------
# STAGE 4 — Final Combined Image (Node + Python + Flutter)
# ---------------------------------------------------------
FROM python:3.13-slim AS combined

WORKDIR /app

# Install Node.js in the Python image
RUN apt-get update && \
    apt-get install -y curl && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install supervisor to manage multiple processes
RUN pip install --no-cache-dir supervisor

# Copy Python packages and bot
COPY --from=bot-builder /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=bot-builder /app/backend/bot-server ./backend/bot-server

# Copy Node backend
COPY --from=node-builder /app/backend/node-server ./backend/node-server

# Copy Flutter build
COPY --from=flutter-builder /app/frontend/build/web ./frontend/build/web

# Create necessary directories for supervisor
RUN mkdir -p /var/log/supervisor /var/run /etc/supervisor/conf.d

# Create supervisor config
COPY <<EOF /etc/supervisor/conf.d/supervisord.conf
[supervisord]
nodaemon=true
user=root
logfile=/var/log/supervisor/supervisord.log
pidfile=/var/run/supervisord.pid
loglevel=info

[program:node-server]
command=node /app/backend/node-server/src/server.js
directory=/app/backend/node-server
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[program:discord-bot]
command=python /app/backend/bot-server/bots/discord_bot/main.py
directory=/app/backend/bot-server
autostart=true
autorestart=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
environment=DISCORD_TOKEN="%(ENV_DISCORD_TOKEN)s"
EOF

EXPOSE 3000

CMD ["/usr/local/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]