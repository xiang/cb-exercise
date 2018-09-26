#!/bin/bash
curl -fsSL get.docker.com -o get-docker.sh
sh get-docker.sh
echo StrictHostKeyChecking no > ~/.ssh/config
git clone https://github.com/xiang/cb-exercise.git
cd cb-exercise/src
sudo docker build -t api .
sudo docker run --rm -p 8080:8080 api
