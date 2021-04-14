#!/bin/bash

echo "Stopping all eos services"

docker exec -it eostutorial chmod 777 /opt/application/scripts/stop.sh
docker exec -it eostutorial /opt/application/scripts/stop.sh

docker-compose down