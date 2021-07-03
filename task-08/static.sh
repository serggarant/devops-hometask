#!/bin/bash

docker run --name hometask-image -d --rm -p 8081:80 hometask-image
docker cp index.html hometask-image:/var/www/html/index.html
