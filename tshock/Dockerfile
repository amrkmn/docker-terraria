FROM alpine:3.21.0 AS base

# Install dependencies
RUN apk add --no-cache curl unzip

ARG TSHOCKVERSION=5.2.4
ARG TERRARIA_VERSION=1.4.4.9

COPY entrypoint.sh /tshock/entrypoint.sh
RUN chmod +x /tshock/entrypoint.sh

ARG TARGETARCH

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

FROM mcr.microsoft.com/dotnet/runtime:8.0

ARG TSHOCKVERSION=5.2.4
ARG TERRARIA_VERSION=1.4.4.9

LABEL org.opencontainers.image.source="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.url="https://github.com/amrkmn/docker-terraria"
LABEL org.opencontainers.image.description="Terraria TShock modded dedicated server"

EXPOSE 7777 7878

ENV TSHOCKVERSION=${TSHOCKVERSION}
ENV TERRARIA_VERSION=${TERRARIA_VERSION}
ENV BASE_DIR=/data
ENV CONFIGPATH=/data/config
ENV LOGPATH=/data/logs
ENV CRASHDIR=/data/crashes
ENV WORLDSELECTPATH=/data/worlds
ENV ADDITIONALPLUGINS=/data/plugins

COPY --from=base /tshock /tshock

RUN cp -r /tshock/ServerPlugins /tshock-plugins

RUN groupadd --gid 1000 terraria && \
    useradd --uid 1000 --gid terraria --no-create-home --shell /usr/sbin/nologin terraria && \
    mkdir -p /data /home/terraria/.local/share/Terraria/Worlds && \
    chown -R terraria:terraria /tshock /tshock-plugins /data /home/terraria

USER terraria

VOLUME ["/data"]

WORKDIR /tshock
ENTRYPOINT ["/tshock/entrypoint.sh"]
