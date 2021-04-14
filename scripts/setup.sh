#!/bin/bash

echo "Building eos wallet external docker volume"
docker volume create --name=wallet-data-volume

echo "Building images"
# docker-compose build --no-cache
docker-compose build

# echo "Initializing docker containers"
docker-compose up -d eostutorial