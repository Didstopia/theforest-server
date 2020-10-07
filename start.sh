#!/usr/bin/env bash

# Enable error handling
set -e
set -o pipefail

# Enable debugging
# set -x

# Print the user we're currently running as
echo "Running as user: $(whoami)"

# Define the install/update function
install_or_update()
{
	# Install The Forest from install.txt
	echo "Installing or updating The Forest.. (this might take a while, be patient)"
	bash /steamcmd/steamcmd.sh +runscript /app/install.txt

	# Terminate if exit code wasn't zero
	if [ $? -ne 0 ]; then
		echo "Exiting, steamcmd install or update failed!"
		exit 1
	fi
}

# Create the necessary folder structure
if [ ! -d "/steamcmd/theforest" ]; then
	echo "Missing /steamcmd/theforest, creating.."
	mkdir -p /steamcmd/theforest
fi

# Install/update steamcmd
echo "Installing/updating steamcmd.."
curl -s http://media.steampowered.com/installer/steamcmd_linux.tar.gz | bsdtar -xvf- -C /steamcmd

install_or_update

# Remove extra whitespace from startup command
THEFOREST_STARTUP_COMMAND=$(echo "$THEFOREST_SERVER_STARTUP_ARGUMENTS" | tr -s " ")

# Configure server game port
if [ ! "$THEFOREST_SERVER_GAME_PORT" = "" ]; then
  echo "Setting server game port to ${THEFOREST_SERVER_GAME_PORT}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -servergameport \"${THEFOREST_SERVER_GAME_PORT}\""
fi

# Configure server query port
if [ ! "$THEFOREST_SERVER_QUERY_PORT" = "" ]; then
  echo "Setting server query port to ${THEFOREST_SERVER_QUERY_PORT}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serverqueryport \"${THEFOREST_SERVER_QUERY_PORT}\""
fi

# Configure server IP
if [ ! "$THEFOREST_SERVER_IP" = "" ]; then
  echo "Setting server IP to ${THEFOREST_SERVER_IP}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serverip \"${THEFOREST_SERVER_IP}\""
else
  SERVER_IP=$(ip route|awk '/scope/ { print $9 }' | tail -n1)
  echo "Setting server IP to ${SERVER_IP} (auto-discovered)"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serverip \"${SERVER_IP}\""
fi

# Configure server password
if [ ! "$THEFOREST_SERVER_PASSWORD" = "" ]; then
  echo "Setting server password to ${THEFOREST_SERVER_PASSWORD}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serverpassword \"${THEFOREST_SERVER_PASSWORD}\""
fi

# Configure server admin password
if [ ! "$THEFOREST_SERVER_ADMIN_PASSWORD" = "" ]; then
  echo "Setting server password to ${THEFOREST_SERVER_ADMIN_PASSWORD}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serverpassword_admin \"${THEFOREST_SERVER_ADMIN_PASSWORD}\""
fi

# Configure server auto-save interval
if [ ! "$THEFOREST_SERVER_AUTOSAVE_INTERVAL" = "" ]; then
  echo "Setting server auto-save interval to ${THEFOREST_SERVER_AUTOSAVE_INTERVAL} minute(s)"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serverautosaveinterval \"${THEFOREST_SERVER_AUTOSAVE_INTERVAL}\""
fi

# Configure extra server startup arguments
if [ ! "$THEFOREST_SERVER_STARTUP_ARGUMENTS_EXTRA" = "" ]; then
  THEFOREST_STARTUP_COMMAND_EXTRA=$(echo "$THEFOREST_SERVER_STARTUP_ARGUMENTS_EXTRA" | tr -s " ")
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} ${THEFOREST_STARTUP_COMMAND_EXTRA}"
fi

# Configure server Steam account
if [ ! "$THEFOREST_SERVER_STEAM_ACCOUNT" = "" ]; then
  echo "Setting server Steam account to ${THEFOREST_SERVER_STEAM_ACCOUNT}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serversteamaccount \"${THEFOREST_SERVER_STEAM_ACCOUNT}\""
fi

# Configure server name last (in case quotes cause any issues)
if [ ! "$THEFOREST_SERVER_NAME" = "" ]; then
  echo "Setting server name to \"${THEFOREST_SERVER_NAME}\""
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -servername \"${THEFOREST_SERVER_NAME}\""
fi

# Set the working directory
cd /steamcmd/theforest

# Make sure the config and save folders exist
# mkdir -p /steamcmd/theforest/{saves,config,logs}
# mkdir -p /app/{saves,config}

# Append the save and config paths to the startup command
# THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -savefolderpath \"Z:/steamcmd/theforest/saves/\" -configfilepath \"Z:/steamcmd/theforest/config/config.cfg\""
# THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -savefolderpath \"/app/saves/\" -configfilepath \"/app/config/config.cfg\""

## FIXME: Also grep out any error lines, for a cleaner output
# Run the server
echo "Starting server with arguments: ${THEFOREST_STARTUP_COMMAND}"
xvfb-run \
  --auto-servernum \
  --server-args='-screen 0 640x480x24:32 -nolisten tcp -nolisten unix' \
  bash -c "wine /steamcmd/theforest/TheForestDedicatedServer.exe ${THEFOREST_STARTUP_COMMAND}" | grep -v "RenderTexture.Create failed: format unsupported - 2." # | grep -v "(Filename: " | grep -v "NullReferenceException" | grep -v "in <filename unknown>:0" | grep -v ":err:ole:" | grep -v "ALSA lib " | grep -v "(this message is harmless)" | grep -v " Unity Child Domain" | grep -v "OnLevelWasLoaded " | grep -v " deprecated " | grep -v " SceneManager.sceneLoaded "

echo "Exiting.."
exit
