# SuperCDMS JupyterLab

## Overview

SLAC maintains a number of JupyterLab images for various research projects.
This repository contains the code used to build the SuperCDMS Docker image, 
and an example Singularity definition file.    

**Dependencies:** 
- Singularity (standard version, not devel)
- Docker CE Edge ([installation guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/))

**Notes:**  
- Docker: requires sudo to build image from Dockerfile
- Docker: ssh access to CDMS git repositories
    - ssh keys are securely managed by the ARG function, and do not linger in the final build
- Singularity: requires that the docker image be hosted in docker hub

## Usage

For usage instructions 
Documentation on the official SuperCDMS JupyterLab image is available to SLAC users via [Confluence](insert url).

### Building the image

If you're interested in building your own local image, `./Docker/Dockerfile` and `./Singularitydef.simg

1. 

To build, simply issue: 

`$ sudo singularity build /path/to/target.simg /path/to/Singularityfile.sdef`

Users will be able to access the image via [web browser](https://jupyter.slac.stanford.edu) 
or submit batch jobs directly to the image by command line.

Users are welcome to tinker with Dockerfile to fit their needs. 
Note, however, that to build a new Singularity image based on the new Docker image, 
the Docker image must be available as a Docker hub repository. 

