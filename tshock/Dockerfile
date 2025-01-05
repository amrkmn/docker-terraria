# Base image setup with platform specification
FROM --platform=${BUILDPLATFORM} alpine:3.21.0 AS base

# Install dependencies
RUN apk add --no-cache \
    curl \
    unzip

# Add the bootstrap file
COPY entrypoint.sh /tshock/entrypoint.sh

# Ensure the entrypoint script is executable
RUN chmod +x /tshock/entrypoint.sh

# TShock version
ENV TSHOCKVERSION=v5.2.1

# Make TARGETPLATFORM available to the container.
ARG TARGETPLATFORM

# Detect and download the correct TShock package based on the target platform using TARGETPLATFORM
RUN set -eux; \
    case "${TARGETPLATFORM}" in \
        'linux/amd64') \
            TSHOCKZIP='TShock-5.2.1-for-Terraria-1.4.4.9-linux-amd64-Release.zip'; \
            ;; \
        'linux/arm64') \
            TSHOCKZIP='TShock-5.2.1-for-Terraria-1.4.4.9-linux-arm64-Release.zip'; \
            ;; \
        *) echo >&2 "error: unsupported TARGETPLATFORM '${TARGETPLATFORM}'."; exit 1 ;; \
    esac; \
    curl -L -o /$TSHOCKZIP https://github.com/Pryaxis/TShock/releases/download/$TSHOCKVERSION/$TSHOCKZIP; \
    unzip /$TSHOCKZIP -d /tshock; \
    tar -xvf /tshock/*.tar -C /tshock && rm /tshock/*.tar; \
    rm /$TSHOCKZIP; \
    chmod +x /tshock/TShock.Server

# Main image setup with platform specification
FROM --platform=${BUILDPLATFORM} mcr.microsoft.com/dotnet/runtime:6.0

# Expose ports
EXPOSE 7777 7878

# Define volumes using /data as the base directory
VOLUME ["/data"]

# Set working directory to /tshock
WORKDIR /tshock

# Copy server files from the /tshock directory to the final image
COPY --from=base /tshock /tshock

# Set entrypoint
ENTRYPOINT ["/tshock/entrypoint.sh"]
