#!/bin/bash

set -e  # stop script if any command fails

echo "==> Building Flutter Web..."
cd frontend
flutter build web --release

echo "==> Back to project root..."
cd ..

echo "==> Building Docker image..."
docker build -t calbot-project .

echo "==> Tagging image..."
docker tag calbot-project:latest ghcr.io/kaewdisorn/calbot-project:latest

echo "==> Pushing to GHCR..."
docker push ghcr.io/kaewdisorn/calbot-project:latest

echo "==> Done!"
