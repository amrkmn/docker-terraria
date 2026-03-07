FROM alpine:3.21.0 AS base

# Install dependencies
RUN apk add --no-cache curl unzip

ARG TSHOCK_VERSION=5.2.4
ARG TERRARIA_VERSION=1.4.4.9

COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ARG TARGETARCH

RUN set -eux; \
    case "$TARGETARCH" in \
        amd64)  ARCH_SUFFIX="amd64" ;; \
        arm64)  ARCH_SUFFIX="arm64" ;; \
        *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac; \
    if [ "$TSHOCK_VERSION" = "latest" ]; then \
        RELEASE_URL="https://api.github.com/repos/Pryaxis/TShock/releases/latest"; \
    else \
        RELEASE_URL="https://api.github.com/repos/Pryaxis/TShock/releases/tags/v${TSHOCK_VERSION}"; \
    fi; \
    DOWNLOAD_URL=$(curl -fsSL "$RELEASE_URL" \
        | grep browser_download_url \
        | grep "linux-${ARCH_SUFFIX}-Release.zip" \
        | cut -d '"' -f 4); \
    curl -fsSL -o /app.zip "$DOWNLOAD_URL"; \
    unzip /app.zip -d /app; \
    tar -xf /app/*.tar -C /app && rm /app/*.tar; \
    rm /app.zip; \
    chmod +x /app/TShock.Server

FROM mcr.microsoft.com/dotnet/runtime:6.0

ARG TSHOCK_VERSION=5.2.4
ARG TERRARIA_VERSION=1.4.4.9

LABEL org.opencontainers.image.source="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.url="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.description="Terraria TShock modded dedicated server"

EXPOSE 7777 7878

ENV TSHOCK_VERSION=${TSHOCK_VERSION}
ENV TERRARIA_VERSION=${TERRARIA_VERSION}
ENV BASE_DIR=/data
ENV CONFIGPATH=/data/config
ENV LOGPATH=/data/logs
ENV CRASHDIR=/data/crashes
ENV WORLDSELECTPATH=/data/worlds
ENV ADDITIONALPLUGINS=/data/plugins

COPY --from=base /app /app

RUN groupadd --gid 1000 terraria && \
    useradd --uid 1000 --gid terraria --no-create-home --shell /usr/sbin/nologin terraria && \
    mkdir -p /data /home/terraria/.local/share/Terraria/Worlds && \
    chown -R terraria:terraria /app /data /home/terraria

USER terraria

VOLUME ["/data"]

WORKDIR /app
ENTRYPOINT ["/app/entrypoint.sh"]
