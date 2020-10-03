#!/bin/bash

./docker_build.sh

docker run -p 0.0.0.0:27015:27015 -p 0.0.0.0:27015:27015/udp -p 0.0.0.0:27016:27016 -p 0.0.0.0:8766:8766 -v $(pwd)/theforest_data:/steamcmd/theforest $@ --name theforest-server -it --rm didstopia/theforest-server:latest
