# Use lightweight Node.js image
FROM node:20-alpine

# Set working directory
WORKDIR /app

# Copy backend package files and install dependencies
COPY backend/node-server/package*.json ./backend/node-server/
WORKDIR /app/backend/node-server
RUN npm install --production

# Copy backend source code
COPY backend/node-server/src ./src

# Copy Flutter build next to backend folder (not inside backend)
WORKDIR /app
COPY frontend/flutter-build/web ./frontend/flutter-build/web

# Expose server port
EXPOSE 3000

# Start backend server
WORKDIR /app/backend/node-server
CMD ["node", "src/server.js"]
