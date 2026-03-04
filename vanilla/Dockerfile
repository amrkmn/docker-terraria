FROM --platform=${BUILDPLATFORM} alpine:3.21.0 AS base

# Install dependencies
RUN apk add --no-cache curl unzip

# Terraria server version (override at build time with --build-arg DL_VERSION=...)
ARG DL_VERSION=1450

# Download and extract only required files
RUN curl -fsSL "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${DL_VERSION}.zip" \
        -o /terraria-server.zip && \
    unzip /terraria-server.zip -d /terraria && \
    mv $(find /terraria -type d -name Linux)/* /server/ && \
    cp $(find /terraria -type f -name serverconfig.txt | head -n 1) /server/serverconfig-default.txt && \
    chmod +x /server/TerrariaServer /server/TerrariaServer.bin.x86_64 && \
    rm -rf /terraria /terraria-server.zip

# Copy and permission the entrypoint
COPY entrypoint.sh /server/entrypoint.sh
RUN chmod +x /server/entrypoint.sh

# Runtime image — debian:bookworm-slim is the upstream base used by the mono project.
# Mono is installed conditionally at build time for ARM64 only; amd64 uses the native binary.
FROM debian:bookworm-slim

ARG TARGETARCH
ARG DL_VERSION=1450

# Bake TARGETARCH into the image so the entrypoint can select the correct binary at runtime
ENV TARGETARCH=${TARGETARCH}
ENV DL_VERSION=${DL_VERSION}

# OCI labels
LABEL org.opencontainers.image.source="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.url="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.description="Terraria vanilla dedicated server"

# Expose server port
EXPOSE 7777

# Environment variables
ENV LOGPATH=/data/logs
ENV WORLDPATH=/data/worlds
ENV WORLD_FILENAME=""
ENV CONFIGPATH=/data/config
ENV CONFIG_FILENAME="serverconfig.txt"

# On ARM64: install mono-runtime and relocate System.dll from the Terraria bundle into
# the Mono GAC so the correct version is used (the bundled one is incompatible otherwise).
# On amd64: no extra dependencies needed — TerrariaServer native ELF is used directly.
RUN if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then \
        apt-get update && \
        apt-get install -y --no-install-recommends ca-certificates mono-runtime && \
        rm -rf /var/lib/apt/lists/*; \
    fi

# Copy server files from the build stage
COPY --from=base /server/ /server/

# On ARM64: relocate System.dll into the Mono GAC after copying server files
RUN if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then \
        mv /server/System.dll /usr/lib/mono/4.5/System.dll; \
    fi

# Create a non-root user and group, then hand off ownership of all runtime paths
RUN groupadd --gid 1000 terraria && \
    useradd --uid 1000 --gid terraria --no-create-home --shell /usr/sbin/nologin terraria && \
    mkdir -p /data && \
    chown -R terraria:terraria /server /data

USER terraria

VOLUME ["/data"]

WORKDIR /server
ENTRYPOINT ["/bin/sh", "/server/entrypoint.sh"]
