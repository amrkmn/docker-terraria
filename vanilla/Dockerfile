FROM alpine:3.21.0 AS base

# Install unzip and clean up after installation
RUN apk add --no-cache unzip

# Add the bootstrap file
COPY entrypoint.sh /server/entrypoint.sh

ENV DL_VERSION=1449
ENV DL_LINK=https://terraria.org/api/download/pc-dedicated-server/terraria-server-${DL_VERSION}.zip
ENV DL_FILE=terraria-server-${DL_VERSION}.zip

# Download and extract only required files
RUN wget -q $DL_LINK -O /$DL_FILE && \
    unzip /$DL_FILE -d /terraria && \
    mv $(find /terraria -type d -name Linux)/* /server && \
    cp $(find /terraria -type f -name serverconfig.txt | head -n 1) /server/serverconfig-default.txt && \
    chmod +x /server/TerrariaServer && \
    chmod +x /server/TerrariaServer.bin.x86_64 && \
    rm -rf /terraria /$DL_FILE

FROM mono:6.10.0.104-slim

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
