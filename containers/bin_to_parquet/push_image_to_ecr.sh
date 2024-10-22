#!/bin/bash

repository_url=$1
aws_region=$2

cd "$(dirname "$0")"
printf "Configurando AWS CLI\n"
printf $AWS_ACCESS_KEY'\n'$AWS_SECRET_ACCESS_KEY'\n'$aws_region'\njson' | aws configure
printf "\nOK\n"

# Build the Docker image locally
docker build -t ebcdic_converter .

# Authenticate Docker to your ECR registry
aws ecr get-login-password --region $aws_region | docker login --username AWS --password-stdin $repository_url

# Tag the Docker image
docker tag ebcdic_converter $repository_url

# Push the Docker image to ECR
docker push $repository_url