#!/bin/bash

# Build web app
docker build -f Dockerfile.web -t myapp-web .

# Build bot
docker build -f Dockerfile.bot -t myapp-bot .

# Run web app
docker run -p 3000:3000 -e PORT=3000 myapp-web

# Run bot (in separate terminal)
docker run -e DISCORD_TOKEN=your_token_here myapp-bot