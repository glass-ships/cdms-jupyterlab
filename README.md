# SuperCDMS JupyterLab

## Overview

SLAC maintains a number of JupyterLab images for various research projects.
This repository contains the code used to build the SuperCDMS Docker beta image, intended for testing new features.
For Release Notes, see the master branch README. 

**Dependencies:** 
- Docker CE Edge ([installation guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/))

**Notes:**  
- Docker requires sudo acces, or that the user be added to the `Docker` group 
- ssh access to CDMS git repositories
    - ssh keys are securely managed by the ARG function, and do not linger in the final build

## Usage

Documentation on the official SuperCDMS JupyterLab image is available to SLAC users via [Confluence](https://confluence.slac.stanford.edu/display/CDMS/How+to+get+started+with+analysis).

If you're interested in building your own Docker image for local use: 

- You'll need to change every instance of `josh@nero` in `./Dockerfile` to reflect your SLAC username
- JupyterLab is installed via pip, so you'll want to add a `RUN` statement at the end of `./Dockerfile` that launches JupyterLab when the container starts up
- `./build.sh` provides an example script that you'll likely want to tailor to fit your needs.
- the build script requires a tag argument, and can be run with the following syntax:  
    ``../cdms-jupyterlab $ bash build.sh '<dockerhub user>/<repository>:<tag>``

## Contribution 

If you'd like to help develop the official SuperCDMS JupyterLab image, you can reach via the [repository](https://github.com/glass-ships/cdms-jupyterlab), or contact Josh Elsarboukh, joshua.elsarboukh@ucdenver.edu
