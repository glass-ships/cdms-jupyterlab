# CDMS JupyterLab

## THIS REPOSITORY HAS BEEN ARCHIVED AND MIGRATED TO [GITLAB](https://gitlab.com/supercdms/CompInfrastructure/cdms-jupyterlab)

### Overview

SLAC maintains a number of JupyterLab images for various research projects.
This repository contains the code used to build an image for dark matter analysis by the SuperCDMS experiment.  
Documentation on the official SuperCDMS JupyterLab image is available to SLAC users via [Confluence](https://confluence.slac.stanford.edu/display/CDMS/How+to+get+started+with+analysis).

**Dependencies:** 
- Docker CE Edge ([installation guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/))

**Notes:**  
- Docker requires sudo acces, or that the user be added to the `Docker` group 
- SSH access to CDMS git repositories
- All cloning is done locally - SSH keys remain secure. 

### Installation

Refer to `build.sh` and `Dockerfile` to get a sense of how the image is put together: 
- `Dockerfile` gives step by step build instructions to Docker daemon
- `build.sh` tells Docker to build image based on `Dockerfile`

### Contributing

See documentation in [gitlab version](https://gitlab.com/supercdms/CompInfrastructure/cdms-jupyterlab).
