# SuperCDMS Jupyterhub Instance

SLAC maintains a number 

**Dependencies:** 

- Singularity (standard version, not devel)
- Docker CE Edge ([installation guide](https://docs.docker.com/install/linux/docker-ce/ubuntu/))

**Notes:**  

Docker image: 
- requires root access to build image from Dockerfile
- ssh access to cdms git repositories
    - ssh keys are securely managed by the ARG function, and do not linger in the final build
- 

A jupyterlab instance tailored to cdms data analysis is currently being developed (release likely by the end of the year).
Only the [Singularity file](cdms-jupyterlab/Singularityfile.sdef) is required to build the Singularity image.
To build, simply issue: 

`$ sudo singularity build /path/to/target.simg /path/to/Singularityfile.sdef`

Users will be able to access the image via [web browser](https://jupyter.slac.stanford.edu) 
or submit batch jobs directly to the image by command line.

Users are welcome to tinker with Dockerfile to fit their needs. 
Note, however, that to build a new Singularity image based on the new Docker image, 
the Docker image must be available as a Docker hub repository. 

**Notes:**

- Singularity build does require root access
- Docker build requires Docker CE Edge (multi-stage build)
- Requires that user has ssh key access to SCDMS git repository
- Build image by running `$ bash build-container.sh` 
- ssh keys are securely managed by the ARG feature, and do not linger in the final build
