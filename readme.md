# Satisfactory Dedicated Server for ARM64 (Docker Container)

This Docker container runs a Satisfactory dedicated server on ARM64 architecture using [FEX-Emu](https://github.com/FEX-Emu/FEX) for x86 emulation. Based on [nitrog0d/palworld-arm64](https://github.com/nitrog0d/palworld-arm64).

## Getting Started

1. **Clone the repository**:
   ```
   git clone <repo-url>
   cd satisfactory-server-arm64
   ```

2. **Create data directories and set permissions**:

   ```
   mkdir -p satisfactory config
   sudo chmod 777 satisfactory config
   sudo chmod +x init-server.sh
   ```

   Or with `chown` (replace `USER_ID:GROUP_ID` with your user's IDs, e.g. `1000:1000`):
   ```
   sudo chown -R USER_ID:GROUP_ID satisfactory config
   ```

   > **Oracle Cloud (OCI):** The `opc` user has IDs `1000:1000`. The `ubuntu` user uses `1001:1001`.

3. **Build the Docker image**:
   ```
   docker build -t satisfactory-arm64 .
   ```

4. **Start the server**:
   ```
   docker compose up -d
   ```

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
