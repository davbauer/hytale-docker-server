#!/usr/bin/env bash
set -e

REPO="davbauer/hytale-docker-server"
INSTALL_DIR="${HYTALE_INSTALL_DIR:-./hytale-server}"

echo ""
echo "Hytale Dedicated Server - Installer"
echo "===================================="
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed."
    echo "Install Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Create directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download docker-compose.yml
echo "Downloading docker-compose.yml..."
curl -fsSL "https://raw.githubusercontent.com/$REPO/main/docker-compose.yml" -o docker-compose.yml

echo ""
echo "Installed to: $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "  cd $INSTALL_DIR"
echo "  docker compose up"
echo ""
