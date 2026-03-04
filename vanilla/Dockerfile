FROM --platform=${BUILDPLATFORM} alpine:3.21.0 AS base

# Install dependencies
RUN apk add --no-cache curl unzip

# Add the bootstrap file
COPY entrypoint.sh /server/entrypoint.sh

# Make TARGETPLATFORM available to the build stage
ARG TARGETPLATFORM

# Terraria server version (override at build time with --build-arg DL_VERSION=...)
ARG DL_VERSION=1449

ENV DL_LINK=https://terraria.org/api/download/pc-dedicated-server/terraria-server-${DL_VERSION}.zip
ENV DL_FILE=terraria-server-${DL_VERSION}.zip

# Download and extract only required files
# The official Terraria server only ships a Linux x86_64 native binary.
# On ARM64, mono TerrariaServer.exe is used instead (handled by entrypoint.sh).
RUN curl -fsSL "$DL_LINK" -o "/$DL_FILE" && \
    unzip "/$DL_FILE" -d /terraria && \
    mv $(find /terraria -type d -name Linux)/* /server && \
    cp $(find /terraria -type f -name serverconfig.txt | head -n 1) /server/serverconfig-default.txt && \
    chmod +x /server/entrypoint.sh && \
    chmod +x /server/TerrariaServer && \
    chmod +x /server/TerrariaServer.bin.x86_64 && \
    rm -rf /terraria "/$DL_FILE"

# Use mono:6 (Mono is required — the Terraria server .exe targets .NET Framework,
# which is not compatible with mcr.microsoft.com/dotnet/runtime)
FROM mono:6-slim

# Expose server port
EXPOSE 7777

# Define environment variables
ENV LOGPATH=/data/logs
ENV WORLDPATH=/data/worlds
ENV WORLD=""
ENV CONFIGPATH=/data/config
ENV CONFIG_FILENAME="serverconfig.txt"

# Create data volume
VOLUME ["/data"]

# Copy only required files from the build stage
COPY --from=base /server/ /server/
WORKDIR /server

ENTRYPOINT ["/bin/sh", "/server/entrypoint.sh"]
