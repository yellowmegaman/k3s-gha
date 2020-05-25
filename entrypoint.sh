#!/bin/bash -e

docker ps

docker pull consul:latest

docker run -d --name=consul consul:latest
