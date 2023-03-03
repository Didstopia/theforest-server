#!/usr/bin/env bash

# Enable error handling
set -e
set -o pipefail

# Enable debugging
# set -x

## TODO: Get the update_check.sh script running! Should be all setup already, I think? Just needs scheduling!?

# Print the user we're currently running as
echo "Running as user: $(whoami)"

# Fix potential steamcmd issues on specific hardware
if [ -z "$CPU_MHZ" ]; then
  echo "NOTICE: CPU speed could not be detected. A default value will be used instead!"
  export CPU_MHZ="1500.000"
fi

# Create the wine directory if it doesn't exist
if [ ! -d "${WINEPREFIX}" ]; then
  echo "Missing ${WINEPREFIX} directory, creating.."
  mkdir -p "${WINEPREFIX}"
fi

# Define the install/update function
install_or_update()
{
	# Install The Forest from install.txt
	echo "Installing or updating The Forest.. (this might take a while, be patient)"
	# bash /steamcmd/steamcmd.sh +runscript /app/install.txt
  /steamcmd/steamcmd.sh +runscript /app/install.txt

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

# Configure server save folder path
if [ ! "$THEFOREST_SERVER_SAVE_FOLDER_PATH" = "" ]; then
  echo "Setting server save folder path to ${THEFOREST_SERVER_SAVE_FOLDER_PATH}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -savefolderpath \"${THEFOREST_SERVER_SAVE_FOLDER_PATH}\""

  # Create the folder if it doesn't exist
  if [ ! -d "${THEFOREST_SERVER_SAVE_FOLDER_PATH}" ]; then
    echo "Creating server save folder.."
    mkdir -p "${THEFOREST_SERVER_SAVE_FOLDER_PATH}"
  fi
fi

# Configure server config file path
if [ ! "$THEFOREST_SERVER_CONFIG_FILE_PATH" = "" ]; then
  # Check if THEFOREST_SERVER_ENABLE_CONFIG_FILE is set to 1, otherwise don't use the config file
  if [ ! "$THEFOREST_SERVER_ENABLE_CONFIG_FILE" = "1" ]; then
    echo "NOTICE: Server config file is not enabled, ignoring config file path and using environment variables as server arguments instead!"
  else
    echo "Setting server config file path to ${THEFOREST_SERVER_CONFIG_FILE_PATH}"
    THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -configfilepath \"${THEFOREST_SERVER_CONFIG_FILE_PATH}\""

    # Create the base directory for the server config file if it doesn't exist
    if [ ! -d "$(dirname "${THEFOREST_SERVER_CONFIG_FILE_PATH}")" ]; then
      echo "Creating server config file base directory.."
      mkdir -p "$(dirname "${THEFOREST_SERVER_CONFIG_FILE_PATH}")"
    fi

    # # Create the folder and an empty config file if it doesn't exist
    # if [ ! -f "${THEFOREST_SERVER_CONFIG_FILE_PATH}" ]; then
    #   echo "Creating server config file.."
    #   mkdir -p "$(dirname "${THEFOREST_SERVER_CONFIG_FILE_PATH}")"
    #   ## TODO: Supposedly the server itself should create a default config file, but not sure if that works?!
    #   # touch "${THEFOREST_SERVER_CONFIG_FILE_PATH}"
    # fi
  fi
fi

# Configure server VAC status
if [ "$THEFOREST_SERVER_ENABLE_VAC" = "1" ]; then
  echo "Enabling server VAC anti-cheat system"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -enableVAC"
fi

# Configure server Steam port
if [ ! "$THEFOREST_SERVER_STEAM_PORT" = "" ]; then
  echo "Setting server Steam port to ${THEFOREST_SERVER_STEAM_PORT}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serversteamport \"${THEFOREST_SERVER_STEAM_PORT}\""
fi

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
  if [ ! "$THEFOREST_SERVER_IP_AUTO" = "1" ]; then
    echo "NOTICE: Server IP is not set, and auto-discovery is disabled."
  else
    SERVER_IP=$(ip route|awk '/scope/ { print $9 }' | tail -n1)
    # If server IP starts with "172.", change it to "0.0.0.0" instead
    if [[ $SERVER_IP == 172.* ]]; then
      SERVER_IP="0.0.0.0"
    fi
    echo "Setting server IP to ${SERVER_IP} (auto-discovered)"
    THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serverip \"${SERVER_IP}\""
  fi
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

# Configure server init type
if [ ! "$THEFOREST_SERVER_INIT_TYPE" = "" ]; then
  echo "Setting server init type to ${THEFOREST_SERVER_INIT_TYPE}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -inittype \"${THEFOREST_SERVER_INIT_TYPE}\""
fi

# Configure server save slot
if [ ! "$THEFOREST_SERVER_SAVE_SLOT" = "" ]; then
  echo "Setting server save slot to ${THEFOREST_SERVER_SAVE_SLOT}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -slot \"${THEFOREST_SERVER_SAVE_SLOT}\""
fi

# Configure server difficulty
if [ ! "$THEFOREST_SERVER_DIFFICULTY" = "" ]; then
  echo "Setting server difficulty to ${THEFOREST_SERVER_DIFFICULTY}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -difficulty \"${THEFOREST_SERVER_DIFFICULTY}\""
fi

# Configure server Steam account
if [ ! "$THEFOREST_SERVER_STEAM_ACCOUNT" = "" ]; then
  echo "Setting server Steam account to ${THEFOREST_SERVER_STEAM_ACCOUNT}"
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} -serversteamaccount \"${THEFOREST_SERVER_STEAM_ACCOUNT}\""
fi

# Configure extra server startup arguments
if [ ! "$THEFOREST_SERVER_STARTUP_ARGUMENTS_EXTRA" = "" ]; then
  THEFOREST_STARTUP_COMMAND_EXTRA=$(echo "$THEFOREST_SERVER_STARTUP_ARGUMENTS_EXTRA" | tr -s " ")
  THEFOREST_STARTUP_COMMAND="${THEFOREST_STARTUP_COMMAND} ${THEFOREST_STARTUP_COMMAND_EXTRA}"
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
  --server-args='-screen 0 1024x768x24 -nolisten tcp -nolisten unix' \
  bash -c "wine64 /steamcmd/theforest/TheForestDedicatedServer.exe ${THEFOREST_STARTUP_COMMAND}" | grep -v "RenderTexture.Create failed: format unsupported - 2." | grep -v ":fixme:" # | grep -v "(Filename: " | grep -v "NullReferenceException" | grep -v "in <filename unknown>:0" | grep -v ":err:ole:" | grep -v "ALSA lib " | grep -v "(this message is harmless)" | grep -v " Unity Child Domain" | grep -v "OnLevelWasLoaded " | grep -v " deprecated " | grep -v " SceneManager.sceneLoaded "

echo "Exiting.."
exit 0
