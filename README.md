# Hytale Dedicated Server - Docker

## Option 1: Docker Compose

1. Create `docker-compose.yml`:

```yaml
services:
  hytale:
    image: eclipse-temurin:25-jdk
    container_name: hytale-server
    stdin_open: true
    tty: true
    working_dir: /app/data
    ports:
      - "5520:5520/udp"
    volumes:
      - hytale-data:/app/data
    environment:
      JAVA_XMS: 4G
      JAVA_XMX: 8G
      SERVER_PORT: 5520
      ENABLE_AOT: "true"
      CHECK_UPDATE: "true"
    entrypoint: ["/bin/bash", "-c"]
    command:
      - |
        apt-get update -qq && apt-get install -y -qq curl > /dev/null 2>&1
        curl -fsSL https://raw.githubusercontent.com/davbauer/hytale-docker-server/main/entrypoint.sh -o /tmp/entrypoint.sh
        exec bash /tmp/entrypoint.sh
    restart: unless-stopped

volumes:
  hytale-data:
```

2. Run:

```bash
docker compose up -d
docker attach hytale-server
```

## Option 2: Docker Run

```bash
docker run -it --name hytale-server \
  -p 5520:5520/udp \
  -v hytale-data:/app/data \
  -e JAVA_XMS=4G -e JAVA_XMX=8G \
  -e SERVER_PORT=5520 -e ENABLE_AOT=true -e CHECK_UPDATE=true \
  --restart unless-stopped \
  eclipse-temurin:25-jdk \
  bash -c 'apt-get update -qq && apt-get install -y -qq curl > /dev/null 2>&1 && curl -fsSL https://raw.githubusercontent.com/davbauer/hytale-docker-server/main/entrypoint.sh -o /tmp/entrypoint.sh && exec bash /tmp/entrypoint.sh'
```

## Setup

1. Approve the **download auth** URL in the logs
2. After server starts, type `/auth login device` and approve again
3. Detach with `Ctrl+P`, `Ctrl+Q`

## Port

Forward **UDP 5520** on your router.

## Reference

- [Hytale Server Manual](https://support.hytale.com/hc/en-us/articles/45326769420827-Hytale-Server-Manual)

## Other


This is a community project and is not affiliated with Hypixel Studios.
