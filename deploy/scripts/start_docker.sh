#!/bin/bash

# Log everything to start_docker.log
exec > /home/ubuntu/start_docker.log 2>&1
set -e

echo "Logging in to ECR..."
sudo aws ecr get-login-password --region us-east-1 | \
sudo docker login --username AWS --password-stdin 557496517362.dkr.ecr.us-east-1.amazonaws.com

echo "Pulling Docker image from ECR..."
sudo docker pull 557496517362.dkr.ecr.us-east-1.amazonaws.com/yt-chrome-plugin:latest

echo "Checking for existing container..."

if [ "$(sudo docker ps -q -f name=yt-chrome-plugin)" ]; then
    echo "Stopping existing container..."
    sudo docker stop yt-chrome-plugin
fi

if [ "$(sudo docker ps -aq -f name=yt-chrome-plugin)" ]; then
    echo "Removing existing container..."
    sudo docker rm yt-chrome-plugin
fi

echo "Starting new container..."
sudo docker run -d \
    -p 80:5000 \
    --name yt-chrome-plugin \
    557496517362.dkr.ecr.us-east-1.amazonaws.com/yt-chrome-plugin:latest

echo "Waiting for app to become healthy..."
for i in $(seq 1 45); do
    if curl -sf http://localhost/health > /dev/null; then
        echo "App is healthy"
        exit 0
    fi
    sleep 2
done

echo "App failed to become healthy; dumping container logs:"
sudo docker logs yt-chrome-plugin --tail 200 || true
exit 1
