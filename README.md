# Glass Ships' Bash Scripts

This repository contains sets of potentially useful scripts for various purposes 

## cdmsdocker

Contains a Dockerfile for building a basic SuperCDMS analysis suite, with the intention of being
web accessible via a jupyter notebook hub. 

**Note:** cloning of SCDMS software requires ssh access to the private git repository. 
As such you will need to pass an accepted ssh key as a build argument for docker:

```
$ docker build \ 
  --build-arg SSH_KEY_PUB=~/.ssh/id_rsa.pub \
  -t cdms \
  -f Dockerfile .
```
 
## root6-sl7

This directory contains scripts for installing ROOT 6 and its pre-requisites on a clean Scientific Linux 7 system. 
See [this document](root6-sl7/README.md) for instructions. 
