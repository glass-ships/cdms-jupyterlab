# ROOT 6 on Scientific Linux 7 / CentOS 7

The purpose of this set of scripts is to install ROOT 6 onto a clean Scientific Linux 7 filesystem. 
Open a terminal and follow the instructions below. 
**Note**: root access is required.

Instructions:

0. If you plan to use `sshfs` to mount remote directories, you will need 
   to enable the EPEL repository before installing:
   - ``$ sudo yum install epel-release``

1. Make sure your system is up to date:
    - ``$ sudo yum update``

2.  Clone this repository and move inside:
    - ``$ git clone http://github.com/glass-ships/glass-scripts.git``
    - ``$ cd glass-scripts/``

3. Install ROOT pre-requisites:
    - ``$ bash root-depends.sh``

4. Compile CMake 3.12 (required by ROOT 6):
    - ``$ bash install-cmake3_12.sh``

5. Install Anaconda3:
    - ``$ bash install-anaconda3.sh``

6. Install boost libraries:
    - ``$ bash install-boost1_67.sh``
    or ``$ conda install boost``

7. Install ROOT 6:
    - ``$ bash install-root.sh``

Potenially useful links if you run into trouble:
- https://root-forum.cern.ch/t/guide-root-6-anaconda-3-6/28395
- https://github.com/AGerrety/ROOT6PYTHON3
- https://github.com/ContinuumIO/anaconda-issues/issues/1734
- https://root-forum.cern.ch/t/how-to-build-root-6-on-scientific-linux/19726
- https://root.cern.ch/root/htmldoc/guides/users-guide/ROOTUsersGuide.html#installing-root
- https://root.cern.ch/build-prerequisites
- https://root.cern.ch/building-root 
