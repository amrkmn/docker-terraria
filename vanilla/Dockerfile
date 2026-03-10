FROM --platform=${BUILDPLATFORM} alpine:3.21.0 AS base

RUN apk add --no-cache curl unzip

ARG DL_VERSION=1456

RUN curl -fsSL "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${DL_VERSION}.zip" \
        -o /terraria-server.zip && \
    unzip /terraria-server.zip -d /terraria && \
    LINUX_DIR=$(find /terraria -type d \( -iname "linux" \) | head -n 1) && \
    mkdir -p /app && \
    mv "$LINUX_DIR"/* /app/ && \
    cp "$(find /terraria -type f -iname 'serverconfig.txt' | head -n 1)" /app/serverconfig-default.txt && \
    chmod +x /app/TerrariaServer /app/TerrariaServer.bin.x86_64 && \
    rm -rf /terraria /terraria-server.zip

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

FROM debian:bookworm-slim

ARG TARGETARCH
ARG DL_VERSION=1456

LABEL org.opencontainers.image.source="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.url="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.description="Terraria vanilla dedicated server"

EXPOSE 7777

ENV LOGPATH=/data/logs
ENV WORLDPATH=/data/worlds
ENV WORLD_FILENAME=""
ENV CONFIGPATH=/data/config
ENV CONFIG_FILENAME="serverconfig.txt"
ENV TARGETARCH=${TARGETARCH}

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then \
        apt-get install -y --no-install-recommends mono-runtime; \
    fi && \
    rm -rf /var/lib/apt/lists/*

COPY --from=base /app/ /app/

RUN if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then \
        mv /app/System.dll /usr/lib/mono/4.5/System.dll; \
    fi

RUN groupadd --gid 1000 terraria && \
    useradd --uid 1000 --gid terraria --no-create-home --shell /usr/sbin/nologin terraria && \
    mkdir -p /data /home/terraria/.local/share/Terraria/Worlds && \
    chown -R terraria:terraria /app /data /home/terraria

USER terraria

VOLUME ["/data"]

WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
