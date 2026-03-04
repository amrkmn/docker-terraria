# docker-terraria

<p align="center">
  <a href="https://github.com/amrkmn/docker-terraria/pkgs/container/terraria"><img alt="vanilla" src="https://img.shields.io/badge/image-vanilla-blue?logo=docker"></a>
  <a href="https://github.com/amrkmn/docker-terraria/pkgs/container/terraria%2Ftshock"><img alt="tshock" src="https://img.shields.io/badge/image-tshock-purple?logo=docker"></a>
  <a href="https://github.com/amrkmn/docker-terraria/actions/workflows/docker.yml"><img alt="CI" src="https://github.com/amrkmn/docker-terraria/actions/workflows/docker.yml/badge.svg"></a>
</p>

Docker images for running [Terraria](https://terraria.org) dedicated servers — both vanilla and [TShock](https://github.com/Pryaxis/TShock)-modded. Multi-arch builds for `linux/amd64` and `linux/arm64`.

## Images

| Image | Registry |
|---|---|
| Vanilla | `ghcr.io/amrkmn/terraria` |
| Vanilla (explicit) | `ghcr.io/amrkmn/terraria/vanilla` |
| TShock | `ghcr.io/amrkmn/terraria/tshock` |

### Tags

- `latest` — most recent build
- `1.4.4.9` — specific Terraria version (vanilla)
- `5.2.3` — specific TShock version
- `1.4.4.9-5.2.3` — Terraria + TShock version pinned together

## Usage

### Vanilla

```sh
docker run -d \
  --name terraria \
  -p 7777:7777 \
  -v /path/to/data:/data \
  -e WORLD="MyWorld.wld" \
  ghcr.io/amrkmn/terraria:latest
```

### TShock

```sh
docker run -d \
  --name terraria-tshock \
  -p 7777:7777 \
  -p 7878:7878 \
  -v /path/to/data:/data \
  -e WORLD="MyWorld.wld" \
  ghcr.io/amrkmn/terraria/tshock:latest
```

> [!TIP]
> Port `7878` is the TShock REST API. You can omit it if you don't need remote management.

### Docker Compose

```yaml
services:
  terraria:
    image: ghcr.io/amrkmn/terraria:latest
    ports:
      - "7777:7777"
    volumes:
      - ./data:/data
    environment:
      WORLD: "MyWorld.wld"
    restart: unless-stopped
```

## Environment Variables

### Vanilla

| Variable | Default | Description |
|---|---|---|
| `WORLD` | _(empty)_ | World filename (e.g. `MyWorld.wld`). If unset, server starts in interactive setup mode. |
| `WORLDPATH` | `/data/worlds` | Directory where world files are stored. |
| `CONFIGPATH` | `/data/config` | Directory for the server config file. |
| `CONFIG_FILENAME` | `serverconfig.txt` | Server config filename. |
| `LOGPATH` | `/data/logs` | Directory for server logs. |

### TShock

| Variable | Default | Description |
|---|---|---|
| `WORLD` | _(empty)_ | World filename to load on startup. |
| `WORLDNAME` | _(empty)_ | Name for a newly auto-created world. |
| `AUTOCREATE` | _(empty)_ | World size for auto-creation: `1` (small), `2` (medium), `3` (large). |
| `PORT` | _(empty)_ | Server port (default `7777`). |
| `MAXPLAYERS` | _(empty)_ | Maximum number of players. |
| `PASSWORD` | _(empty)_ | Server password. |
| `MOTD` | _(empty)_ | Message of the day. |
| `DIFFICULTY` | _(empty)_ | World difficulty: `0` (normal), `1` (expert), `2` (master), `3` (journey). |
| `WORLD_EVIL` | _(empty)_ | World evil type: `0` (random), `1` (corruption), `2` (crimson). |
| `IP` | _(empty)_ | IP address to bind to. |
| `CONFIGPATH` | `/data/config` | Directory for TShock config files. |
| `LOGPATH` | `/data/logs` | Directory for logs. |
| `CRASHDIR` | `/data/crashes` | Directory for crash reports. |
| `WORLDSELECTPATH` | `/data/worlds` | Directory where world files are stored. |
| `ADDITIONALPLUGINS` | `/data/plugins` | Directory for additional TShock plugins. |
| `SECURE` | `false` | Enable VAC-style anti-cheat. |
| `AUTOSHUTDOWN` | `false` | Shutdown server when last player leaves. |
| `FORCEUPDATE` | `false` | Force server updates even without players. |
| `IGNOREVERSION` | `false` | Ignore version checks. |
| `LOGCLEAR` | `false` | Clear logs on startup. |

## Data Volume

Both images use `/data` as the base volume. Mount a host directory there to persist your worlds, config, and logs across container restarts.

```
/data
├── config/       # Server configuration files
├── worlds/       # World files (.wld)
├── logs/         # Server logs
├── crashes/      # TShock crash reports (tshock only)
└── plugins/      # Additional plugins (tshock only)
```

> [!NOTE]
> On first run, if no config file is found, the vanilla image will copy a default `serverconfig.txt` into `/data/config` automatically.

## Releasing a New Version

Use the included `release.sh` script to tag and trigger a new build:

```sh
# Vanilla
./release.sh vanilla 1.4.4.9

# TShock
./release.sh tshock 1.4.4.9 5.2.3
```

The script validates your input and git state, creates the tag, and pushes it to GitHub. The Actions workflow then updates the Dockerfile, builds multi-arch images, and pushes them to the registry automatically.
