#!/bin/bash

# Base directory for all paths
: "${BASE_DIR:=/data}"
: "${CONFIGPATH:=$BASE_DIR/config}"
: "${LOGPATH:=$BASE_DIR/logs}"
: "${CRASHDIR:=$BASE_DIR/crashes}"
: "${WORLDSELECTPATH:=$BASE_DIR/worlds}"
: "${ADDITIONALPLUGINS:=$BASE_DIR/plugins}"

# Ensure all necessary directories exist
for dir in "$CONFIGPATH" "$LOGPATH" "$CRASHDIR" "$WORLDSELECTPATH" "$ADDITIONALPLUGINS"; do
    if [ ! -d "$dir" ]; then
        echo "Creating directory: $dir"
        mkdir -p "$dir"
    fi
done

# Map environment variables and default values to TShock parameters
ARGS="-configpath $CONFIGPATH -logpath $LOGPATH -crashdir $CRASHDIR -worldselectpath $WORLDSELECTPATH -additionalplugins $ADDITIONALPLUGINS"

[ -n "$IP" ] && ARGS="$ARGS -ip $IP"
[ -n "$PORT" ] && ARGS="$ARGS -port $PORT"
[ -n "$MAXPLAYERS" ] && ARGS="$ARGS -maxplayers $MAXPLAYERS"
[ -n "$WORLD" ] && ARGS="$ARGS -world $WORLDSELECTPATH/$WORLD"
[ -n "$WORLDNAME" ] && ARGS="$ARGS -worldname $WORLDNAME"
[ -n "$AUTOCREATE" ] && ARGS="$ARGS -autocreate $AUTOCREATE"
[ -n "$CONFIG" ] && ARGS="$ARGS -config $CONFIG"
[ -n "$IGNOREVERSION" ] && ARGS="$ARGS -ignoreversion"
[ -n "$FORCEUPDATE" ] && ARGS="$ARGS -forceupdate"
[ -n "$PASSWORD" ] && ARGS="$ARGS -pass $PASSWORD"
[ -n "$MOTD" ] && ARGS="$ARGS -motd \"$MOTD\""
[ -n "$AUTOSHUTDOWN" ] && ARGS="$ARGS -autoshutdown"
[ -n "$SECURE" ] && ARGS="$ARGS -secure"
[ -n "$LOGFORMAT" ] && ARGS="$ARGS -logformat $LOGFORMAT"
[ -n "$LOGCLEAR" ] && ARGS="$ARGS -logclear"
[ -n "$WORLD_EVIL" ] && ARGS="$ARGS -worldevil $WORLD_EVIL"
[ -n "$DIFFICULTY" ] && ARGS="$ARGS -difficulty $DIFFICULTY"

# Add any additional arguments passed to the container
ARGS="$ARGS $@"

echo "Starting TShock server with arguments: $ARGS"

# Ensure the TShock directory exists, then execute the TShock server from the /tshock directory
if [ ! -d "/tshock" ]; then
    echo "Error: /tshock directory does not exist! Creating it..."
    mkdir -p /tshock
fi

exec /tshock/TShock.Server $ARGS
