#!/bin/bash

echo "Stopping all eos services"

docker exec -it eosio chmod 777 /opt/application/scripts/stop.sh
docker exec -it eosio /opt/application/scripts/stop.sh

docker-compose down