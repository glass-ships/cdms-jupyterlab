#!/bin/bash

#export GITKEY=$(cat ~/.ssh/id_rsa)

docker build \
    --build-arg SSHKEYPVT="$(cat ~/.ssh/id_rsa)" \
    --build-arg SSHKEYPUB="$(cat ~/.ssh/id_rsa.pub)" \
    -t cdms -f Dockerfile .

