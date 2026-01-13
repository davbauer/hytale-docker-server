# Hytale Dedicated Server - Docker

A simple Docker Compose setup for running a Hytale dedicated server.

## Requirements

- [Docker](https://docker.com) with Docker Compose

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/davbauer/hytale-docker-server/main/install.sh | bash
cd hytale-server
docker compose up
```

## Manual Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/davbauer/hytale-docker-server.git
   cd hytale-docker-server
   ```

2. Start the server:
   ```bash
   docker compose up
   ```

3. **Downloader Auth** - Open the URL shown in logs and approve (downloads game files ~1.4GB)

4. **Server Auth** - Once the server starts, type `/auth login device` in the console:
   ```bash
   docker attach hytale-server
   # Type: /auth login device
   # Open the new URL and approve
   # Detach with Ctrl+P, Ctrl+Q
   ```

## Authentication

Hytale requires **two separate authentications**:

| Auth | Purpose | When |
|------|---------|------|
| Downloader | Download game files | First run (automatic) |
| Server | Accept player connections | After server starts |

The server auth is stored in memory by default. To persist credentials across restarts:
```
/auth persistence Encrypted
```

## Configuration

Edit the `environment` section in `docker-compose.yml` to customize your server:

```yaml
environment:
  JAVA_XMS: 4G           # Minimum memory
  JAVA_XMX: 8G           # Maximum memory
  SERVER_PORT: 5520      # UDP port
  ENABLE_AOT: "true"     # AOT cache for faster startup
  CHECK_UPDATE: "true"   # Check for updates on start
```

After changing settings, restart with:
```bash
docker compose down
docker compose up
```

## Commands

Run in background:
```bash
docker compose up -d
```

View logs:
```bash
docker compose logs -f
```

Attach to console:
```bash
docker attach hytale-server
```
Detach with `Ctrl+P` then `Ctrl+Q`

Stop server:
```bash
docker compose down
```

## Port Forwarding

Forward **UDP port 5520** on your router to your server's IP address.

## License

MIT License - see [LICENSE](LICENSE) for details.

---

This is a community project and is not affiliated with Hypixel Studios.
