#!/bin/bash

repository_url=$1

cd "$(dirname "$0")"

# Build the Docker image locally
docker build -t ebcdic_converter .

# Authenticate Docker to your ECR registry
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $repository_url

# Tag the Docker image
docker tag ebcdic_converter $repository_url

# Push the Docker image to ECR
docker push $repository_url