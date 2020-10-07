#!/bin/bash

set -e
set -o pipefail

./docker_build.sh

docker run \
  -p 0.0.0.0:26015:26015 \
  -p 0.0.0.0:26015:26015/udp \
  -p 0.0.0.0:26016:26016 \
  -p 0.0.0.0:26016:26016/udp \
  -p 0.0.0.0:8766:8766 \
  -p 0.0.0.0:8766:8766/udp \
  -e THEFOREST_SERVER_AUTOSAVE_INTERVAL=1 \
  -v $(pwd)/theforest_data/game:/steamcmd/theforest \
  -v $(pwd)/theforest_data/appdata:/app/.wine/drive_c/users/docker/AppData/LocalLow/SKS/TheForestDedicatedServer/ds \
  $@ \
  --name theforest-server \
  -it \
  --rm \
  didstopia/theforest-server:latest
