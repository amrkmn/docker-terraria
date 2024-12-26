#!/bin/bash

echo "Bootstrap:"
echo "world=$WORLD"
echo "logpath=$LOGPATH"

# Define paths
WORLD_PATH="$WORLDPATH/$WORLD"

# Check for server configuration
if [ ! -f "$CONFIGPATH/$CONFIG_FILENAME" ]; then
    echo "Server configuration not found, running with default server configuration."
    echo "Please ensure your desired $CONFIG_FILENAME file is volumed into Docker: -v <path_to_config_file>:$CONFIGPATH"
    cp ./serverconfig-default.txt "$CONFIGPATH/$CONFIG_FILENAME"
fi

# Handle world file
if [ -z "$WORLD" ]; then
    echo "No world file specified in environment WORLD."
    if [ -z "$@" ]; then
        echo "Running server setup without additional arguments..."
    else
        echo "Running server with command flags: $@"
    fi
    mono TerrariaServer.exe -config "$CONFIGPATH/$CONFIG_FILENAME" -logpath "$LOGPATH" "$@"
else
    echo "Environment WORLD specified"
    if [ -f "$WORLD_PATH" ]; then
        echo "Loading world file: $WORLD..."
        mono TerrariaServer.exe -config "$CONFIGPATH/$CONFIG_FILENAME" -logpath "$LOGPATH" -world "$WORLD_PATH" "$@"
    else
        echo "Unable to locate world file at $WORLD_PATH."
        echo "Please ensure your world file is volumed into Docker: -v <path_to_world_file>:$WORLDPATH"
        exit 1
    fi
fi
