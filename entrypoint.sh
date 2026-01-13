#!/bin/bash
set -e

#=== Colors ===#
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}           ${GREEN}Hytale Dedicated Server${NC}                        ${CYAN}║${NC}"
echo -e "${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

mkdir -p /app/data/universe /app/data/mods /app/data/logs
cd /app/data

#=== Detect architecture ===#
ARCH=$(uname -m)
case $ARCH in
    x86_64|amd64) DOWNLOADER="hytale-downloader-linux-amd64" ;;
    aarch64|arm64) DOWNLOADER="hytale-downloader-linux-arm64" ;;
    *) echo -e "${RED}[✗]${NC} Unsupported architecture: $ARCH"; exit 1 ;;
esac

#=== Check if already installed ===#
if [ -f HytaleServer.jar ] && [ -f Assets.zip ]; then
    echo -e "${GREEN}[✓]${NC} Server files found"
    
    #=== Check for updates ===#
    if [ "${CHECK_UPDATE}" = "true" ] && [ -f "$DOWNLOADER" ]; then
        echo -e "${BLUE}[i]${NC} Checking for updates..."
        UPDATE_OUTPUT=$(./$DOWNLOADER -print-version 2>/dev/null || echo "")
        if [ -n "$UPDATE_OUTPUT" ]; then
            echo -e "${BLUE}[i]${NC} Latest version: $UPDATE_OUTPUT"
        fi
    fi
else
    #=== Fresh install ===#
    echo -e "${YELLOW}[1/4]${NC} Installing tools..."
    apt-get update -qq
    apt-get install -y -qq unzip > /dev/null 2>&1
    echo -e "${GREEN}[✓]${NC} Tools installed"
    
    #=== Download hytale-downloader ===#
    if [ ! -f "$DOWNLOADER" ]; then
        echo -e "${YELLOW}[2/4]${NC} Downloading hytale-downloader ($ARCH)..."
        curl -fSL --progress-bar https://downloader.hytale.com/hytale-downloader.zip -o /tmp/dl.zip
        unzip -q -o /tmp/dl.zip -d /app/data
        rm -f /tmp/dl.zip
        chmod +x $DOWNLOADER
        echo -e "${GREEN}[✓]${NC} Downloader ready"
    else
        echo -e "${GREEN}[✓]${NC} Downloader already present"
    fi
    
    #=== Download game files ===#
    echo -e "${YELLOW}[3/4]${NC} Downloading Hytale server files..."
    echo ""
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  DOWNLOADER AUTHENTICATION (Step 1 of 2)${NC}"
    echo -e "${NC}  Open the URL below and approve to download game files${NC}"
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    ./$DOWNLOADER
    
    echo ""
    echo -e "${YELLOW}[4/4]${NC} Extracting files..."
    
    GAME_ZIP=$(ls -t *.zip 2>/dev/null | grep -E "^[0-9]{4}\." | head -1)
    if [ -n "$GAME_ZIP" ]; then
        echo -e "${BLUE}[i]${NC} Extracting $GAME_ZIP..."
        unzip -q -o "$GAME_ZIP"
        
        [ -f Server/HytaleServer.jar ] && mv Server/HytaleServer.jar .
        [ -f Server/HytaleServer.aot ] && mv Server/HytaleServer.aot .
        [ -d Server/Licenses ] && mv Server/Licenses .
        rmdir Server 2>/dev/null || true
        
        echo -e "${GREEN}[✓]${NC} Extraction complete"
    else
        echo -e "${RED}[✗]${NC} No game zip found!"
        exit 1
    fi
fi

#=== Verify files ===#
if [ ! -f HytaleServer.jar ]; then
    echo -e "${RED}[✗]${NC} HytaleServer.jar not found!"
    exit 1
fi
if [ ! -f Assets.zip ]; then
    echo -e "${RED}[✗]${NC} Assets.zip not found!"
    exit 1
fi

#=== Show config ===#
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Server Configuration${NC}"
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
echo -e "  Port:       ${YELLOW}UDP ${SERVER_PORT}${NC}"
echo -e "  Memory:     ${YELLOW}${JAVA_XMS} - ${JAVA_XMX}${NC}"
echo -e "  AOT Cache:  ${YELLOW}${ENABLE_AOT}${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
echo -e "${YELLOW}  SERVER AUTHENTICATION REQUIRED${NC}"
echo -e "${NC}  Run this command after server starts:${NC}"
echo -e "${GREEN}    /auth login device${NC}"
echo -e "${NC}  Then open the URL and approve to allow player connections.${NC}"
echo -e "${NC}  To persist auth: /auth persistence Encrypted${NC}"
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
echo ""
echo -e "${GREEN}  Starting server...${NC}"
echo ""

#=== Build Java args ===#
JAVA_ARGS="-Xms${JAVA_XMS} -Xmx${JAVA_XMX}"

if [ "${ENABLE_AOT}" = "true" ] && [ -f HytaleServer.aot ]; then
    JAVA_ARGS="$JAVA_ARGS -XX:AOTCache=HytaleServer.aot"
    echo -e "${BLUE}[i]${NC} AOT cache enabled"
fi

#=== Start server ===#
exec java $JAVA_ARGS -jar HytaleServer.jar \
    --assets Assets.zip \
    --bind 0.0.0.0:${SERVER_PORT}
