#!/bin/sh
set -e

# Select the correct server binary based on architecture.
# On ARM64/ARM: use mono with TerrariaServer.exe (no native binary available).
# On amd64: use the native TerrariaServer ELF directly.
if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then
    set -- mono TerrariaServer.exe
else
    set -- ./TerrariaServer
fi

# Ensure config directory exists and has a config file
mkdir -p "$CONFIGPATH"
if [ ! -f "$CONFIGPATH/$CONFIG_FILENAME" ]; then
    echo "No config file found at $CONFIGPATH/$CONFIG_FILENAME — copying default."
    echo "Mount your own config with: -v <path>:$CONFIGPATH"
    cp ./serverconfig-default.txt "$CONFIGPATH/$CONFIG_FILENAME"
fi

# Launch the server
if [ -z "$WORLD_FILENAME" ]; then
    echo "No world file specified in environment WORLD_FILENAME."
    exec "$@" -config "$CONFIGPATH/$CONFIG_FILENAME" -logpath "$LOGPATH" -worldpath "$WORLDPATH"
else
    WORLD_PATH="$WORLDPATH/$WORLD_FILENAME"
    if [ -f "$WORLD_PATH" ]; then
        exec "$@" -config "$CONFIGPATH/$CONFIG_FILENAME" -logpath "$LOGPATH" -world "$WORLD_PATH"
    else
        echo "Error: world file not found at $WORLD_PATH"
        echo "Mount your world with: -v <path>:$WORLDPATH"
        exit 1
    fi
fi
