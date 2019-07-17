# SuperCDMS JupyterLab

## Overview

SLAC maintains a number of JupyterLab images for various research projects.
This repository contains the code used to build an image for dark matter analysis by the SuperCDMS experiment.

**Dependencies:** 
- Docker CE Edge ([installation guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/))

**Notes:**  
- Docker requires sudo acces, or that the user be added to the `Docker` group 
- SSH access to CDMS git repositories
- All cloning is done locally - SSH keys remain secure. 

## Usage

Documentation on the official SuperCDMS JupyterLab image is available to SLAC users via [Confluence](https://confluence.slac.stanford.edu/display/CDMS/How+to+get+started+with+analysis).

If you're interested in building your own Docker image for local use: 

- You'll need to change every instance of `josh@nero` in `./build.sh` to reflect your SLAC username
- JupyterLab is installed via pip, so you'll want to add a `RUN` statement at the end of `./Dockerfile` that launches JupyterLab when the container starts up
	- You may need to provide some environment variables for JupyterLab to run properly. Check any error output for clues about where to start. 
		- (I'll update this documentation with more useful information as I learn more about these variables)
- `./build.sh` provides an example script that you'll likely want to adjust to fit your needs.

## Contribution 

# SuperCDMS JupyterLab

## Overview

SLAC maintains a number of JupyterLab images for various research projects.
This repository contains the code used to build an image for dark matter analysis by the SuperCDMS experiment.

**Dependencies:** 
- Docker CE Edge ([installation guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/))

**Notes:**  
- Docker requires sudo acces, or that the user be added to the `Docker` group 
- SSH access to CDMS git repositories
- All cloning is done locally - SSH keys remain secure. 

## Usage

Documentation on the official SuperCDMS JupyterLab image is available to SLAC users via [Confluence](https://confluence.slac.stanford.edu/display/CDMS/How+to+get+started+with+analysis).

If you're interested in building your own Docker image for local use: 

- You'll need to change every instance of `josh@nero` in `./build.sh` to reflect your SLAC username
- JupyterLab is installed via pip, so you'll want to add a `RUN` statement at the end of `./Dockerfile` that launches JupyterLab when the container starts up
	- You may need to provide some environment variables for JupyterLab to run properly. Check any error output for clues about where to start. 
		- (I'll update this documentation with more useful information as I learn more about these variables)
- `./build.sh` provides an example script that you'll likely want to adjust to fit your needs.

## Contribution 

# Contributing - SuperCDMS JupyterLab

If you'd like to make changes to the CDMS JupyterLab analysis environment, you should contribute to the develop branch of this repository.

0. Checkout the repository and switch to develop branch:
    - `$ git clone https://gitlab.com/supercdms/CompInfrastructure/cdms-jupyterlab`
    - `$ cd cdms-jupyterlab`
    - `$ git checkout develop`

1. For changes to the Docker image itself:
- Make any changes and push to develop, for example:
    - `$ git commit -a -m 'updated a thing'`
    - `$ git push`

2. Changes to CDMS packages should be made to the master branch:
    - pyCAP
    - scdmsPyTools
    - tutorials
    - python_colorschemes
    - etc.

3. Build image and push to Docker hub:
- Option A:
    - let josh know to build a new image
    - it'll be reflected shortly in the cdms spawner options

- Option B:
    - login to docker (ask Josh for login info?)
    - build using script (use tag '1.6b' for now)
    - push image to docker hub
    - the end

Maybe in the future:
- automated builds / CI through gitlab?

