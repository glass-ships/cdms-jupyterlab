#!/bin/bash

docker build \
    --build-arg SSHKEYPVT="$(cat ~/.ssh/id_rsa)" \
    --build-arg SSHKEYPUB="$(cat ~/.ssh/id_rsa.pub)" \
    --build-arg SSHHOSTS="$(cat ~/.ssh/known_hosts)" \
    -t cdms \
    --rm \
    -f Dockerfile .
