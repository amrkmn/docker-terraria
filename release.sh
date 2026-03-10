#!/bin/sh
set -e

USAGE="Usage:
  ./release.sh vanilla <version> [seq]             e.g. ./release.sh vanilla 1.4.5.5 2
  ./release.sh tshock <terraria> <tshock> [seq]    e.g. ./release.sh tshock 1.4.5.5 6.0.0 2"

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

validate_seq() {
    echo "$1" | grep -qE '^[0-9]+$' || {
        echo "Error: '$1' is not a valid sequence number (expected a positive integer)"
        exit 1
    }
}

case "$IMAGE" in
    vanilla)
        VERSION="$2"
        SEQ="$3"
        if [ -z "$VERSION" ]; then
            echo "Error: vanilla requires a version."
            echo "$USAGE"
            exit 1
        fi
        validate_version "$VERSION"
        if [ -n "$SEQ" ]; then
            validate_seq "$SEQ"
            TAG="vanilla-${VERSION}-${SEQ}"
        else
            TAG="vanilla-${VERSION}"
        fi
        ;;
    tshock)
        TERRARIA_VERSION="$2"
        TSHOCK_VERSION="$3"
        SEQ="$4"
        if [ -z "$TERRARIA_VERSION" ] || [ -z "$TSHOCK_VERSION" ]; then
            echo "Error: tshock requires both a Terraria version and a TShock version."
            echo "$USAGE"
            exit 1
        fi
        validate_version "$TERRARIA_VERSION"
        validate_version "$TSHOCK_VERSION"
        if [ -n "$SEQ" ]; then
            validate_seq "$SEQ"
            TAG="tshock-${TERRARIA_VERSION}-${TSHOCK_VERSION}-${SEQ}"
        else
            TAG="tshock-${TERRARIA_VERSION}-${TSHOCK_VERSION}"
        fi
        ;;
    *)
        echo "Error: unknown image '$IMAGE'. Must be 'vanilla' or 'tshock'."
        echo "$USAGE"
        exit 1
        ;;
esac

check_seq() {
    PREFIX="$1"
    NEW_SEQ="$2"
    EXISTING=$(git tag --list "${PREFIX}" "${PREFIX}-*" 2>/dev/null)
    HIGHEST=0
    for t in $EXISTING; do
        SUFFIX="${t#$PREFIX}"
        if [ -z "$SUFFIX" ]; then
            SEQ_NUM=1
        else
            SEQ_NUM="${SUFFIX#-}"
            echo "$SEQ_NUM" | grep -qE '^[0-9]+$' || continue
        fi
        if [ "$SEQ_NUM" -gt "$HIGHEST" ]; then
            HIGHEST="$SEQ_NUM"
        fi
    done
    EXPECTED=$((HIGHEST + 1))
    if [ "$NEW_SEQ" -ne "$EXPECTED" ]; then
        echo "Error: sequence gap detected. Highest existing build for '${PREFIX}' is ${HIGHEST}, so next must be ${EXPECTED} (got ${NEW_SEQ})."
        exit 1
    fi
}

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" != "main" ]; then
    echo "Error: you must be on 'main' to release (currently on '$BRANCH')."
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "Error: working tree is dirty. Commit or stash your changes first."
    exit 1
fi

git fetch origin main --tags --quiet
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Error: your branch is not up to date with origin/main. Run 'git pull' first."
    exit 1
fi

if [ -n "$SEQ" ]; then
    case "$IMAGE" in
        vanilla) check_seq "vanilla-${VERSION}" "$SEQ" ;;
        tshock)  check_seq "tshock-${TERRARIA_VERSION}-${TSHOCK_VERSION}" "$SEQ" ;;
    esac
fi

if git rev-parse "$TAG" >/dev/null 2>&1; then
    echo "Error: tag '$TAG' already exists locally."
    exit 1
fi
if git ls-remote --tags origin "refs/tags/$TAG" | grep -qF "refs/tags/$TAG"; then
    echo "Error: tag '$TAG' already exists on remote."
    exit 1
fi

echo "Creating tag: $TAG"
git tag "$TAG"
git push origin "$TAG"
echo "Done. GitHub Actions will now build and push the $IMAGE image."
