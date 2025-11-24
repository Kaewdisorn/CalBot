# ---------------------------------------------------------
# STAGE 1 — Build Flutter Web
# ---------------------------------------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS flutter-builder

WORKDIR /app/frontend

# Copy Flutter project
COPY frontend/ .

# Enable Flutter web
RUN flutter config --enable-web

# Build release
RUN flutter build web --release


# ---------------------------------------------------------
# STAGE 2 — Build Node Backend
# ---------------------------------------------------------
FROM node:20-alpine AS backend-builder

WORKDIR /app/backend/node-server

# Copy only package files first (better caching)
COPY backend/node-server/package*.json ./

RUN npm install --production

# Copy backend source
COPY backend/node-server/src ./src


# ---------------------------------------------------------
# STAGE 3 — Final Lightweight Image
# ---------------------------------------------------------
FROM node:20-alpine

WORKDIR /app

# Copy backend build from stage 2
COPY --from=backend-builder /app/backend/node-server ./backend/node-server

# Copy Flutter build from stage 1
COPY --from=flutter-builder /app/frontend/build/web ./frontend/build/web

EXPOSE 3000

WORKDIR /app/backend/node-server
CMD ["node", "src/server.js"]
