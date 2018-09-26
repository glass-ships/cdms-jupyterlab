#!/bin/bash

export SSH_KEY_PUB=$(cat ~/.ssh/id_rsa.pub)

docker build --build-arg SSH_KEY_PUB="$SSH_KEY_PUB" -t cdms -f Dockerfile .

