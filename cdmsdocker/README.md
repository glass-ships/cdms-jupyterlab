# SuperCDMS Dockerfile 


## Notes

- Requires Docker CE Edge (multi-stage build)
- Requires that user has ssh key access to SCDMS git repository
- Build image by running `$ bash build.sh` 
    - ssh keys are securely managed and do not linger in the final build
