#!/usr/bin/env bash

docker build \
    --build-arg SSHKEYPVT="$(cat ~/.ssh/id_rsa)" \
    --build-arg SSHKEYPUB="$(cat ~/.ssh/id_rsa.pub)" \
    --build-arg SSHHOSTS="$(cat ~/.ssh/known_hosts)" \
    -t detlab/cdms-jupyterlab:0.1.0 \
    --rm \
    -f Dockerfile .
