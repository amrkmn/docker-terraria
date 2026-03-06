FROM --platform=${BUILDPLATFORM} alpine:3.21.0 AS base

RUN apk add --no-cache curl unzip

ARG DL_VERSION=1455

RUN curl -fsSL "https://terraria.org/api/download/pc-dedicated-server/terraria-server-${DL_VERSION}.zip" \
        -o /terraria-server.zip && \
    unzip /terraria-server.zip -d /terraria && \
    LINUX_DIR=$(find /terraria -type d \( -iname "linux" \) | head -n 1) && \
    mkdir -p /server && \
    mv "$LINUX_DIR"/* /server/ && \
    cp "$(find /terraria -type f -iname 'serverconfig.txt' | head -n 1)" /server/serverconfig-default.txt && \
    chmod +x /server/TerrariaServer /server/TerrariaServer.bin.x86_64 && \
    rm -rf /terraria /terraria-server.zip

COPY entrypoint.sh /server/entrypoint.sh
RUN chmod +x /server/entrypoint.sh

FROM debian:bookworm-slim

ARG TARGETARCH
ARG DL_VERSION=1455

ENV TARGETARCH=${TARGETARCH}
ENV DL_VERSION=${DL_VERSION}

LABEL org.opencontainers.image.source="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.url="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.description="Terraria vanilla dedicated server"

EXPOSE 7777

ENV LOGPATH=/data/logs
ENV WORLDPATH=/data/worlds
ENV WORLD_FILENAME=""
ENV CONFIGPATH=/data/config
ENV CONFIG_FILENAME="serverconfig.txt"

RUN if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then \
        apt-get update && \
        apt-get install -y --no-install-recommends ca-certificates mono-runtime && \
        rm -rf /var/lib/apt/lists/*; \
    fi

COPY --from=base /server/ /server/

RUN if [ "$TARGETARCH" = "arm64" ] || [ "$TARGETARCH" = "arm" ]; then \
        mv /server/System.dll /usr/lib/mono/4.5/System.dll; \
    fi

RUN groupadd --gid 1000 terraria && \
    useradd --uid 1000 --gid terraria --no-create-home --shell /usr/sbin/nologin terraria && \
    mkdir -p /data /home/terraria/.local/share/Terraria/Worlds && \
    chown -R terraria:terraria /server /data /home/terraria

USER terraria

VOLUME ["/data"]

WORKDIR /server
ENTRYPOINT ["/bin/sh", "/server/entrypoint.sh"]
