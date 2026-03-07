#!/bin/sh
set -e

# Seed plugins from the baked-in snapshot on first run or when TShock version changes.
# /app/ServerPlugins contains the default plugins from the image.
# /data/plugins is the user-facing volume — empty on a fresh mount.
VERSION_FILE="$ADDITIONALPLUGINS/.tshock-version"

if [ -z "$(ls -A "$ADDITIONALPLUGINS" 2>/dev/null)" ] || \
   [ "$(cat "$VERSION_FILE" 2>/dev/null)" != "$TSHOCK_VERSION" ]; then
    echo "Seeding default plugins into $ADDITIONALPLUGINS"
    mkdir -p "$ADDITIONALPLUGINS"
    cp -r /app/ServerPlugins/. "$ADDITIONALPLUGINS/"
    echo "$TSHOCK_VERSION" > "$VERSION_FILE"
fi

# Ensure all necessary directories exist
for dir in "$CONFIGPATH" "$LOGPATH" "$CRASHDIR" "$WORLDSELECTPATH"; do
    [ -d "$dir" ] || mkdir -p "$dir"
done

# Build argument list from environment variables.
# Use a positional parameter set to avoid word-splitting issues with values
# that may contain spaces (e.g. MOTD, paths).
set -- \
    -configpath "$CONFIGPATH" \
    -logpath "$LOGPATH" \
    -crashdir "$CRASHDIR" \
    -worldselectpath "$WORLDSELECTPATH" \
    -additionalplugins "$ADDITIONALPLUGINS"

[ -n "$IP" ]             && set -- "$@" -ip "$IP"
[ -n "$PORT" ]           && set -- "$@" -port "$PORT"
[ -n "$MAXPLAYERS" ]     && set -- "$@" -maxplayers "$MAXPLAYERS"
[ -n "$WORLD_FILENAME" ] && set -- "$@" -world "$WORLDSELECTPATH/$WORLD_FILENAME"
[ -n "$WORLDNAME" ]      && set -- "$@" -worldname "$WORLDNAME"
[ -n "$AUTOCREATE" ]     && set -- "$@" -autocreate "$AUTOCREATE"
[ -n "$CONFIG" ]         && set -- "$@" -config "$CONFIG"
[ -n "$PASSWORD" ]       && set -- "$@" -pass "$PASSWORD"
[ -n "$MOTD" ]           && set -- "$@" -motd "$MOTD"
[ -n "$LOGFORMAT" ]      && set -- "$@" -logformat "$LOGFORMAT"
[ -n "$WORLD_EVIL" ]     && set -- "$@" -worldevil "$WORLD_EVIL"
[ -n "$DIFFICULTY" ]     && set -- "$@" -difficulty "$DIFFICULTY"

[ "$IGNOREVERSION" = "true" ] && set -- "$@" -ignoreversion
[ "$FORCEUPDATE"   = "true" ] && set -- "$@" -forceupdate
[ "$AUTOSHUTDOWN"  = "true" ] && set -- "$@" -autoshutdown
[ "$SECURE"        = "true" ] && set -- "$@" -secure
[ "$LOGCLEAR"      = "true" ] && set -- "$@" -logclear

echo "Starting TShock $TSHOCK_VERSION (Terraria $TERRARIA_VERSION)"

exec /app/TShock.Server "$@"
