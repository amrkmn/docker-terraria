#!/bin/sh
set -e

USAGE="Usage:
  ./release.sh vanilla <version>          e.g. ./release.sh vanilla 1.4.4.9
  ./release.sh tshock <terraria> <tshock> e.g. ./release.sh tshock 1.4.4.9 5.2.3"

# ── Argument validation ────────────────────────────────────────────────────────

IMAGE="$1"

if [ -z "$IMAGE" ]; then
    echo "Error: no image specified."
    echo "$USAGE"
    exit 1
fi

validate_version() {
    echo "$1" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$' || {
        echo "Error: '$1' is not a valid version (expected format: x.x.x or x.x.x.x)"
        exit 1
    }
}

case "$IMAGE" in
    vanilla)
        VERSION="$2"
        if [ -z "$VERSION" ]; then
            echo "Error: vanilla requires a version."
            echo "$USAGE"
            exit 1
        fi
        validate_version "$VERSION"
        TAG="vanilla-${VERSION}"
        ;;
    tshock)
        TERRARIA_VERSION="$2"
        TSHOCK_VERSION="$3"
        if [ -z "$TERRARIA_VERSION" ] || [ -z "$TSHOCK_VERSION" ]; then
            echo "Error: tshock requires both a Terraria version and a TShock version."
            echo "$USAGE"
            exit 1
        fi
        validate_version "$TERRARIA_VERSION"
        validate_version "$TSHOCK_VERSION"
        TAG="tshock-${TERRARIA_VERSION}-${TSHOCK_VERSION}"
        ;;
    *)
        echo "Error: unknown image '$IMAGE'. Must be 'vanilla' or 'tshock'."
        echo "$USAGE"
        exit 1
        ;;
esac

# ── Git checks ─────────────────────────────────────────────────────────────────

# Must be on main
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
    echo "Error: you must be on 'main' to release (currently on '$BRANCH')."
    exit 1
fi

# Working tree must be clean
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: working tree is dirty. Commit or stash your changes first."
    exit 1
fi

# Must be up to date with remote
git fetch origin main --quiet
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Error: your branch is not up to date with origin/main. Run 'git pull' first."
    exit 1
fi

# Tag must not already exist
if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Error: tag '$TAG' already exists."
    exit 1
fi

# ── Release ────────────────────────────────────────────────────────────────────

echo "Creating tag: $TAG"
git tag "$TAG"
git push origin "$TAG"
echo "Done. GitHub Actions will now build and push the $IMAGE image."
