# Satisfactory Dedicated Server for ARM64 (Docker Container)

This Docker container runs a Satisfactory dedicated server on ARM64 architecture using [FEX-Emu](https://github.com/FEX-Emu/FEX) for x86 emulation. Based on [nitrog0d/palworld-arm64](https://github.com/nitrog0d/palworld-arm64).

> **ARM64 only.** This image runs on ARM64 hosts (e.g. Oracle Cloud Ampere, AWS Graviton). If you want to build the image yourself instead of pulling it, you must do so on an ARM64 machine — building on x86-64 will fail by design.

## Getting Started

1. **Clone the repository**:
   ```
   git clone <repo-url>
   cd satisfactory-server-arm64
   ```

2. **Create data directories and set permissions**:

   ```
   mkdir -p satisfactory config
   sudo chmod +x init-server.sh
   ```

   The container's `steam` user runs as UID `1000`. If your host user is also UID `1000` (the default on most Ubuntu servers), the directories you just created are already owned correctly — nothing else needed.

   If your host user has a different UID, transfer ownership:
   ```
   sudo chown -R 1000:1000 satisfactory config
   ```

   > **Oracle Cloud (OCI):** The `ubuntu` user has IDs `1001:1001`, so the `chown` step is required. The older `opc` user uses `1000:1000` and does not need it.

3. **Start the server**:
   ```
   docker compose up -d
   ```

   On first start, SteamCMD (~5 MB) and the game server (~5 GB) are downloaded automatically. Subsequent starts skip the download unless a game update is available.

5. **Open the required ports**:

   | Protocol | Port |
   |----------|------|
   | TCP + UDP | 7777 |
   | TCP | 8888 |

   Open these in your system firewall and, if using Oracle Cloud, in the VCN Security List.

## Managing the Server

| Action | Command |
|--------|---------|
| Stop | `docker compose down` |
| View logs | `docker compose logs -f` |
| Shell access | `docker exec -it satisfactory-server bash` |

## Configuration

### Server Parameters

Edit `docker-compose.yml` to change ports or pass extra parameters to the server via `EXTRA_PARAMS`:

| Option | Description | Default |
|--------|-------------|---------|
| `-multihome=<ip>` | Bind to a specific IP instead of all interfaces | all interfaces |
| `-ServerQueryPort=<port>` | Query port (shown in the Server Manager UI) | UDP/15777 |
| `-BeaconPort=<port>` | Beacon port | UDP/15000 |
| `-Port=<port>` | Game port | UDP/7777 |
| `-DisablePacketRouting` | Disable the packet router | — |

Example:
```
EXTRA_PARAMS=-ServerQueryPort=17531 -BeaconPort=17532 -Port=17533
```

### Auto-update

Set whether the server checks for game updates on each startup:
```yaml
environment:
  - ALWAYS_UPDATE_ON_START=true
```
