#!/bin/bash

# Base directory for all paths
BASE_DIR=${BASE_DIR:-/data}
CONFIGPATH=${CONFIGPATH:-$BASE_DIR/config}
LOGPATH=${LOGPATH:-$BASE_DIR/logs}
CRASHDIR=${CRASHDIR:-$BASE_DIR/crashes}
WORLDSELECTPATH=${WORLDSELECTPATH:-$BASE_DIR/worlds}
ADDITIONALPLUGINS=${ADDITIONALPLUGINS:-$BASE_DIR/plugins}

# Create necessary directories if they don't exist
for dir in "$CONFIGPATH" "$LOGPATH" "$CRASHDIR" "$WORLDSELECTPATH" "$ADDITIONALPLUGINS"; do
    [ -d "$dir" ] || { echo "Creating directory: $dir"; mkdir -p "$dir"; }
done

# Validate boolean values
validate_boolean() {
    [[ "$1" == "true" || "$1" == "false" ]] && echo "$1" || echo "false"
}

# Map environment variables to TShock arguments
ARGS=(
    "-configpath $CONFIGPATH"
    "-logpath $LOGPATH"
    "-crashdir $CRASHDIR"
    "-worldselectpath $WORLDSELECTPATH"
    "-additionalplugins $ADDITIONALPLUGINS"
)

[[ -n "$IP" ]] && ARGS+=("-ip $IP")
[[ -n "$PORT" ]] && ARGS+=("-port $PORT")
[[ -n "$MAXPLAYERS" ]] && ARGS+=("-maxplayers $MAXPLAYERS")
[[ -n "$WORLD" ]] && ARGS+=("-world $WORLDSELECTPATH/$WORLD")
[[ -n "$WORLDNAME" ]] && ARGS+=("-worldname $WORLDNAME")
[[ -n "$AUTOCREATE" ]] && ARGS+=("-autocreate $AUTOCREATE")
[[ -n "$CONFIG" ]] && ARGS+=("-config $CONFIG")
[[ -n "$PASSWORD" ]] && ARGS+=("-pass $PASSWORD")
[[ -n "$MOTD" ]] && ARGS+=("-motd \"$MOTD\"")
[[ -n "$LOGFORMAT" ]] && ARGS+=("-logformat $LOGFORMAT")
[[ -n "$WORLD_EVIL" ]] && ARGS+=("-worldevil $WORLD_EVIL")
[[ -n "$DIFFICULTY" ]] && ARGS+=("-difficulty $DIFFICULTY")
[[ "$(validate_boolean "$IGNOREVERSION")" == "true" ]] && ARGS+=("-ignoreversion")
[[ "$(validate_boolean "$FORCEUPDATE")" == "true" ]] && ARGS+=("-forceupdate")
[[ "$(validate_boolean "$AUTOSHUTDOWN")" == "true" ]] && ARGS+=("-autoshutdown")
[[ "$(validate_boolean "$SECURE")" == "true" ]] && ARGS+=("-secure")
[[ "$(validate_boolean "$LOGCLEAR")" == "true" ]] && ARGS+=("-logclear")

# Add additional arguments passed to the script
ARGS+=("$@")

echo "Starting TShock server with arguments: ${ARGS[*]}"

# Ensure the TShock directory exists
[ -d "/tshock" ] || { echo "Error: /tshock directory does not exist! Creating it..."; mkdir -p /tshock; }

# Execute the TShock server
exec /tshock/TShock.Server "${ARGS[@]}"
