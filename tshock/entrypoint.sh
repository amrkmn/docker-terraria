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
    [ -d "$dir" ] || {
        echo "Creating directory: $dir"
        mkdir -p "$dir"
    }
done

# Map environment variables and default values to TShock parameters
ARGS="-configpath $CONFIGPATH -logpath $LOGPATH -crashdir $CRASHDIR -worldselectpath $WORLDSELECTPATH -additionalplugins $ADDITIONALPLUGINS"

# Validate boolean values
validate_boolean() {
    [[ "$1" == "true" || "$1" == "false" ]] && echo "$1" || echo "false"
}

[ -n "$IP" ] && ARGS="$ARGS -ip $IP"
[ -n "$PORT" ] && ARGS="$ARGS -port $PORT"
[ -n "$MAXPLAYERS" ] && ARGS="$ARGS -maxplayers $MAXPLAYERS"
[ -n "$WORLD" ] && ARGS="$ARGS -world $WORLDSELECTPATH/$WORLD"
[ -n "$WORLDNAME" ] && ARGS="$ARGS -worldname $WORLDNAME"
[ -n "$AUTOCREATE" ] && ARGS="$ARGS -autocreate $AUTOCREATE"
[ -n "$CONFIG" ] && ARGS="$ARGS -config $CONFIG"
[ -n "$PASSWORD" ] && ARGS="$ARGS -pass $PASSWORD"
[ -n "$MOTD" ] && ARGS="$ARGS -motd \"$MOTD\""
[ -n "$LOGFORMAT" ] && ARGS="$ARGS -logformat $LOGFORMAT"
[ -n "$WORLD_EVIL" ] && ARGS="$ARGS -worldevil $WORLD_EVIL"
[ -n "$DIFFICULTY" ] && ARGS="$ARGS -difficulty $DIFFICULTY"

[ "$(validate_boolean "$IGNOREVERSION")" == "true" ] && ARGS="$ARGS -ignoreversion"
[ "$(validate_boolean "$FORCEUPDATE")" == "true" ] && ARGS="$ARGS -forceupdate"
[ "$(validate_boolean "$AUTOSHUTDOWN")" == "true" ] && ARGS="$ARGS -autoshutdown"
[ "$(validate_boolean "$SECURE")" == "true" ] && ARGS="$ARGS -secure"
[ "$(validate_boolean "$LOGCLEAR")" == "true" ] && ARGS="$ARGS -logclear"

# Add any additional arguments passed to the container
ARGS="$ARGS $@"

echo "Starting TShock server with arguments: $ARGS"

# Ensure the TShock directory exists, then execute the TShock server from the /tshock directory
[ -d "/tshock" ] || {
    echo "Error: /tshock directory does not exist! Creating it..."
    mkdir -p /tshock
}

exec /tshock/TShock.Server $ARGS
