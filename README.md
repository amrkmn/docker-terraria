# docker-terraria

[![Vanilla](https://img.shields.io/github/v/tag/amrkmn/docker-terraria?filter=vanilla-*&label=vanilla&color=blue)](https://github.com/amrkmn/docker-terraria/pkgs/container/terraria%2Fvanilla)
[![TShock](https://img.shields.io/github/v/tag/amrkmn/docker-terraria?filter=tshock-*&label=tshock&color=purple)](https://github.com/amrkmn/docker-terraria/pkgs/container/terraria%2Ftshock)
[![CI](https://github.com/amrkmn/docker-terraria/actions/workflows/docker.yml/badge.svg)](https://github.com/amrkmn/docker-terraria/actions/workflows/docker.yml)

Docker images for running a [Terraria](https://terraria.org) dedicated server — vanilla or with [TShock](https://tshock.co) — on `linux/amd64` and `linux/arm64`.

## Images

| Image | Description |
|---|---|
| `ghcr.io/amrkmn/terraria/vanilla` | Vanilla Terraria server |
| `ghcr.io/amrkmn/terraria/tshock` | TShock-modded Terraria server |

### Tags

**Vanilla:** `latest`, `1.4.5.5`

**TShock:** `latest`, `6.0.0`, `1.4.5.5-6.0.0`

## Quick start

### Vanilla

```sh
docker run -d \
  --name terraria \
  -it \
  -p 7777:7777 \
  -v ./data:/data \
  -e WORLD_FILENAME=myworld.wld \
  ghcr.io/amrkmn/terraria/vanilla:latest
```

### TShock

```sh
docker run -d \
  --name terraria \
  -it \
  -p 7777:7777 \
  -p 7878:7878 \
  -v ./data:/data \
  -e WORLD_FILENAME=myworld.wld \
  ghcr.io/amrkmn/terraria/tshock:latest
```

### Docker Compose

```yaml
services:
  terraria:
    image: ghcr.io/amrkmn/terraria/vanilla:latest
    container_name: terraria
    stdin_open: true
    tty: true
    environment:
      WORLD_FILENAME: myworld.wld
    ports:
      - "7777:7777"
    volumes:
      - ./data:/data
    restart: unless-stopped

```

## Configuration

### Vanilla environment variables

| Variable | Default | Description |
|---|---|---|
| `WORLD_FILENAME` | _(empty)_ | World file name (e.g. `myworld.wld`). If unset, server starts in interactive mode. |
| `WORLDPATH` | `/data/worlds` | Directory where world files are stored. |
| `CONFIGPATH` | `/data/config` | Directory for config files. |
| `CONFIG_FILENAME` | `serverconfig.txt` | Server config file name. |
| `LOGPATH` | `/data/logs` | Directory for log output. |

### TShock environment variables

| Variable | Default | Description |
|---|---|---|
| `WORLD_FILENAME` | _(empty)_ | World file name (e.g. `myworld.wld`). If unset, server starts in interactive mode. |
| `WORLDNAME` | _(empty)_ | Name of the world to auto-create. |
| `AUTOCREATE` | _(empty)_ | World size to auto-create: `1` (small), `2` (medium), `3` (large). |
| `PORT` | _(empty)_ | Port to listen on (default `7777`). |
| `MAXPLAYERS` | _(empty)_ | Maximum number of players. |
| `PASSWORD` | _(empty)_ | Server password. |
| `MOTD` | _(empty)_ | Message of the day. |
| `DIFFICULTY` | _(empty)_ | World difficulty: `0` (normal), `1` (expert), `2` (master), `3` (journey). |
| `WORLD_EVIL` | _(empty)_ | World evil type: `0` (random), `1` (corruption), `2` (crimson). |
| `IP` | _(empty)_ | Bind to a specific IP address. |
| `CONFIGPATH` | `/data/config` | Directory for config files. |
| `LOGPATH` | `/data/logs` | Directory for log output. |
| `CRASHDIR` | `/data/crashes` | Directory for crash dumps. |
| `WORLDSELECTPATH` | `/data/worlds` | Directory where world files are stored. |
| `ADDITIONALPLUGINS` | `/data/plugins` | Directory for additional TShock plugins. |
| `SECURE` | _(empty)_ | Set to `true` to enable VAC-style cheat protection. |
| `AUTOSHUTDOWN` | _(empty)_ | Set to `true` to shut down when the last player leaves. |
| `FORCEUPDATE` | _(empty)_ | Set to `true` to force world updates even with no players. |
| `IGNOREVERSION` | _(empty)_ | Set to `true` to ignore TShock version checks. |
| `LOGCLEAR` | _(empty)_ | Set to `true` to clear log files on startup. |

## Data volume

All persistent data lives under `/data`:

```
/data/
├── config/       # Server and TShock config files
├── worlds/       # World save files
├── logs/         # Log output
├── crashes/      # Crash dumps (TShock only)
└── plugins/      # Additional TShock plugins (TShock only)
```

> [!NOTE]
> On first run, the vanilla server copies a default `serverconfig.txt` into `/data/config` if none exists. TShock seeds default plugins into `/data/plugins` from the image snapshot.

> [!IMPORTANT]
> The container runs as user `terraria` (UID/GID `1000`). If you mount a host directory as `/data`, ensure it is writable by UID `1000`:
> ```sh
> chown -R 1000:1000 ./data
> ```

## ARM64 support

The vanilla image uses `mono` to run `TerrariaServer.exe` on `arm64` (since Terraria only ships a native `x86_64` binary). The correct runtime is selected automatically at container startup.

## TShock plugins

The TShock image snapshots the default plugins bundled with TShock into `/tshock-plugins` at build time. On first run, if `/data/plugins` is empty, the default plugins are copied there. To add custom plugins, place `.dll` files in your `/data/plugins` mount.

## Releasing

Use `release.sh` to tag and trigger a new build:

```sh
# Vanilla
./release.sh vanilla 1.4.5.5

# TShock (terraria-version tshock-version)
./release.sh tshock 1.4.5.5 6.0.0
```

This validates your branch is up to date, checks for duplicate tags locally and remotely, creates the tag, and pushes it to trigger the GitHub Actions workflow.
