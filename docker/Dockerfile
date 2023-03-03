FROM --platform=linux/amd64 didstopia/base:steamcmd-ubuntu-18.04

LABEL maintainer="Didstopia <support@didstopia.com>"

# Fix apt-get warnings
ARG DEBIAN_FRONTEND=noninteractive

# Run as a non-root user by default
ENV PGID 1000
ENV PUID 1000

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      libsdl2-2.0-0:i386 \
      winbind \
      xvfb \
      wine-stable \
      wine32 \
      wine64 \
      screen \
      net-tools \
      iproute2 && \
    rm -rf /var/lib/apt/lists/*

# Configure wine environment variables
# ENV WINEPREFIX=/winedata/WINE64
# ENV WINEPREFIX=/steamcmd/theforest/wine
ENV WINEPREFIX /app/data/wine
ENV WINEARCH=win64
# ENV DISPLAY=:1.0

# Create the volume directories
# RUN mkdir -p /steamcmd/rust /usr/share/nginx/html /var/log/nginx
RUN mkdir -p /steamcmd/theforest ${WINEPREFIX}

# Add the overlay
ADD overlay /

# Add the steamcmd installation script
# ADD install.txt /app/install.txt

# Copy the Rust startup script
# ADD start.sh /app/start.sh

# Copy the Rust update check script
# ADD update_check.sh /app/update_check.sh

# Copy extra files
# COPY README.md LICENSE.md /app/

# Set the current working directory
WORKDIR /

# Fix permissions
RUN chown -R $PGID:$PUID \
      /steamcmd \
      /app

## TODO: Figure out the actual ports needed + protocol (TCP, UDP or both)
# Expose necessary ports
EXPOSE 8766/tcp
EXPOSE 8766/udp
EXPOSE 26015/tcp
EXPOSE 26015/udp
EXPOSE 26016/tcp
EXPOSE 26016/udp

## TODO: Rewrite the default args and stuff if and when we get linux support going?!
# Setup default environment variables for the server
## TODO: Does "-nographics" or "-nosteamclient" even work?!
#ENV THEFOREST_SERVER_STARTUP_ARGUMENTS "-batchmode -load -nographics -nosteamclient -enableVAC"
# ENV THEFOREST_SERVER_STARTUP_ARGUMENTS "-batchmode -dedicated -nographics -nosteamclient"
ENV THEFOREST_SERVER_STARTUP_ARGUMENTS "-batchmode -dedicated"
ENV THEFOREST_SERVER_STARTUP_ARGUMENTS_EXTRA ""
ENV THEFOREST_SERVER_SAVE_FOLDER_PATH "/app/data/saves"
ENV THEFOREST_SERVER_CONFIG_FILE_PATH "/app/data/config.cfg"
ENV THEFOREST_SERVER_ENABLE_CONFIG_FILE "0"
ENV THEFOREST_SERVER_ENABLE_VAC "1"
## TODO: Configure some kind of "fool proof" New/Continue logic in the startup script!
ENV THEFOREST_SERVER_INIT_TYPE "New"
# ENV THEFOREST_SERVER_INIT_TYPE "Continue"
ENV THEFOREST_SERVER_SAVE_SLOT "1"
ENV THEFOREST_SERVER_DIFFICULTY "Normal"
ENV THEFOREST_SERVER_NAME "The Forest (Docker)"
ENV THEFOREST_SERVER_STEAM_PORT "8766"
ENV THEFOREST_SERVER_GAME_PORT "27015"
ENV THEFOREST_SERVER_QUERY_PORT "27016"
ENV THEFOREST_SERVER_IP ""
ENV THEFOREST_SERVER_IP_AUTO "1"
ENV THEFOREST_SERVER_PASSWORD ""
ENV THEFOREST_SERVER_ADMIN_PASSWORD ""
ENV THEFOREST_SERVER_STEAM_ACCOUNT ""
ENV THEFOREST_SERVER_AUTOSAVE_INTERVAL "15"
ENV THEFOREST_SERVER_UPDATE_CHECKING "1"
ENV THEFOREST_SERVER_UPDATE_BRANCH "public"

## TODO: Is this still necessary if we don't use wine?
# Define directories to take ownership of
# ENV CHOWN_DIRS "/app,/steamcmd,/usr/share/nginx/html,/var/log/nginx"
## FIXME: This only works if the WINEPREFIX directory already exists on
##        container startup, which it won't on a fresh install,
##        when it's mounted as a volume, so the base image itself
##        should always ensure that the paths exist before running chown on them!
#ENV CHOWN_DIRS "/app,/steamcmd,${WINEPREFIX},/dev/stdout,/dev/stderr"
ENV CHOWN_DIRS "/app,/steamcmd,/dev/stdout,/dev/stderr"

## TODO: Re-enable if all is well
# Expose the volumes
# VOLUME [ "/steamcmd/theforest" ]
VOLUME [ "/steamcmd/theforest", "/app/data" ]
# VOLUME [ "/steamcmd/theforest", "/steamcmd/theforest/saves", "/steamcmd/theforest/config", "/steamcmd/theforest/logs" ]
# VOLUME [ "/steamcmd/theforest", "/app/config", "/app/saves", "/app/.wine/drive_c/users/docker/AppData/LocalLow/SKS/TheForestDedicatedServer" ]
# VOLUME [ "/steamcmd/theforest", "/app/config", "/app/saves" ]

# Start the server
CMD [ "bash", "/app/start.sh"]
