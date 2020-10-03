#!/bin/bash

./docker_build.sh

docker run \
  -p 0.0.0.0:26015:26015 \
  -p 0.0.0.0:26015:26015/udp \
  -p 0.0.0.0:26016:26016 \
  -p 0.0.0.0:26016:26016/udp \
  -p 0.0.0.0:8766:8766 \
  -p 0.0.0.0:8766:8766/udp \
  -v $(pwd)/theforest_data:/steamcmd/theforest \
  $@ \
  --name theforest-server \
  -it \
  --rm \
  didstopia/theforest-server:latest
