FROM alpine:3.21.0 AS base

# Install dependencies
RUN apk add --no-cache curl unzip

# TShock and Terraria target versions (override at build time).
# Set TSHOCKVERSION=latest to always pull the newest release.
ARG TSHOCKVERSION=5.2.3
ARG TERRARIA_VERSION=1.4.4.9

# Copy and permission the entrypoint
COPY entrypoint.sh /tshock/entrypoint.sh
RUN chmod +x /tshock/entrypoint.sh

# TARGETARCH is injected by Docker Buildx (e.g. "amd64", "arm64").
# Must be declared as ARG to make it available inside RUN.
ARG TARGETARCH

# Download the correct TShock release from the GitHub API for the target architecture.
RUN set -eux; \
    case "$TARGETARCH" in \
        amd64)  ARCH_SUFFIX="amd64" ;; \
        arm64)  ARCH_SUFFIX="arm64" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac; \
    if [ "$TSHOCKVERSION" = "latest" ]; then \
        RELEASE_URL="https://api.github.com/repos/Pryaxis/TShock/releases/latest"; \
    else \
        RELEASE_URL="https://api.github.com/repos/Pryaxis/TShock/releases/tags/v${TSHOCKVERSION}"; \
    fi; \
    DOWNLOAD_URL=$(curl -fsSL "$RELEASE_URL" \
        | grep browser_download_url \
        | grep "linux-${ARCH_SUFFIX}-Release.zip" \
        | cut -d '"' -f 4); \
    curl -fsSL -o /tshock.zip "$DOWNLOAD_URL"; \
    unzip /tshock.zip -d /tshock; \
    tar -xf /tshock/*.tar -C /tshock && rm /tshock/*.tar; \
    rm /tshock.zip; \
    chmod +x /tshock/TShock.Server

# Runtime image — .NET 8.0 LTS (EOL Nov 2026)
FROM mcr.microsoft.com/dotnet/runtime:8.0

ARG TSHOCKVERSION=5.2.3
ARG TERRARIA_VERSION=1.4.4.9

# OCI labels
LABEL org.opencontainers.image.source="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.url="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.description="Terraria TShock modded dedicated server"

# Expose game and REST API ports
EXPOSE 7777 7878

# Environment variables
ENV TSHOCKVERSION=${TSHOCKVERSION}
ENV TERRARIA_VERSION=${TERRARIA_VERSION}
ENV BASE_DIR=/data
ENV CONFIGPATH=/data/config
ENV LOGPATH=/data/logs
ENV CRASHDIR=/data/crashes
ENV WORLDSELECTPATH=/data/worlds
ENV ADDITIONALPLUGINS=/data/plugins

# Copy server files from the build stage
COPY --from=base /tshock /tshock

# Snapshot the default plugins into /tshock-plugins (not a volume).
# The entrypoint seeds /data/plugins from here on first run so bundled
# plugins are not lost when /data is mounted as an external volume.
RUN cp -r /tshock/ServerPlugins /tshock-plugins

# Create a non-root user and group, then hand off ownership of all runtime paths
RUN groupadd --gid 1000 terraria && \
    useradd --uid 1000 --gid terraria --no-create-home --shell /usr/sbin/nologin terraria && \
    mkdir -p /data && \
    chown -R terraria:terraria /tshock /tshock-plugins /data

USER terraria

VOLUME ["/data"]

WORKDIR /tshock
ENTRYPOINT ["/tshock/entrypoint.sh"]
