# Base image — no platform override so the builder runs natively on TARGETPLATFORM.
# Using BUILDPLATFORM here would cause a mismatch when cross-compiling because
# the downloaded binaries are platform-specific.
FROM alpine:3.21.0 AS base

# Install dependencies
RUN apk add --no-cache \
    curl \
    unzip

# Add the bootstrap file
COPY entrypoint.sh /tshock/entrypoint.sh

# Ensure the entrypoint script is executable
RUN chmod +x /tshock/entrypoint.sh

# TShock version and the Terraria version it targets (override at build time)
ARG TSHOCKVERSION=5.2.3
ARG TERRARIA_VERSION=1.4.4.9

# Make TARGETPLATFORM available to the build stage
ARG TARGETPLATFORM

# Detect and download the correct TShock package based on the target platform
RUN set -eux; \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            TSHOCKZIP="TShock-${TSHOCKVERSION}-for-Terraria-${TERRARIA_VERSION}-linux-amd64-Release.zip"; \
            ;; \
        'linux/arm64') \
            TSHOCKZIP="TShock-${TSHOCKVERSION}-for-Terraria-${TERRARIA_VERSION}-linux-arm64-Release.zip"; \
            ;; \
        *) echo >&2 "error: unsupported TARGETPLATFORM '${TARGETPLATFORM}'."; exit 1 ;; \
    esac; \
    curl -fsSL -o "/$TSHOCKZIP" "https://github.com/Pryaxis/TShock/releases/download/v${TSHOCKVERSION}/${TSHOCKZIP}"; \
    unzip "/$TSHOCKZIP" -d /tshock; \
    tar -xf /tshock/*.tar -C /tshock && rm /tshock/*.tar; \
    rm "/$TSHOCKZIP"; \
    chmod +x /tshock/TShock.Server

# Main image — .NET 8.0 LTS (EOL Nov 2026); TShock targets .NET 6+ which is compatible.
# .NET 6.0 reached EOL November 2024.
FROM mcr.microsoft.com/dotnet/runtime:8.0

# Expose ports
EXPOSE 7777 7878

# Define volumes using /data as the base directory
VOLUME ["/data"]

# Set working directory to /tshock
WORKDIR /tshock

# Copy server files from the build stage
COPY --from=base /tshock /tshock

# Set entrypoint
ENTRYPOINT ["/tshock/entrypoint.sh"]
