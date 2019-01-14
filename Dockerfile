##########################################################################################
# Dockerfile for creation of a SuperCDMS analysis suite image
# Jupyterhub support incoming
##########################################################################################

#### intermediate image
FROM centos:7 as intermediate

## install git
RUN yum -y upgrade
RUN yum install -y git

## supply credentials
ARG SSHKEYPUB
ARG SSHKEYPVT
ARG SSHHOSTS

RUN mkdir /root/.ssh && \
    echo "$SSHKEYPUB" > /root/.ssh/id_rsa.pub && \
    echo "$SSHKEYPVT" > /root/.ssh/id_rsa && \
    echo "$SSHHOSTS" > /root/.ssh/known_hosts

COPY ssh-config /root/.ssh/config

RUN chmod 600 /root/.ssh/config && \
    chmod 600 /root/.ssh/id_rsa && \
    chmod 644 /root/.ssh/known_hosts

## clone cdms repos
WORKDIR /packages
RUN git clone josh@nero:/data/git/Analysis/pyCAP.git

WORKDIR /packages
RUN git clone josh@nero:/data/git/Analysis/scdmsPyTools.git && \
    cd scdmsPyTools/scdmsPyTools/BatTools && \
    rm -rf BatCommon && \
    git clone josh@nero:/data/git/Reconstruction/BatCommon.git && \
    cd BatCommon && \
    rm -rf IOLibrary && \
    git clone josh@nero:/data/git/DAQ/IOLibrary && \
    cd ../../.. && \
    git checkout master && \
    git submodule update --init --recursive 

WORKDIR /
RUN git clone josh@nero:/data/git/Analysis/tutorials.git

##########################################################################################

#### build image

#FROM slaclab/slac-jupyterlab
FROM slaclab/slac-jupyterlab-gpu:20190106.0 
USER root

## pull repos from intermediate build
COPY --from=intermediate /packages/ /packages/
COPY --from=intermediate /tutorials /packages/tutorials

## Install dependencies for Boost and ROOT
RUN sudo yum -y upgrade && \
    sudo yum install -y libcurl-devel mysql-devel net-tools sudo centos-release-scl \
     make wget git patch gcc-c++ gcc binutils libX11-devel libXpm-devel libXft-devel \
     libXext-devel gcc-gfortran openssl-devel pcre-devel mesa-libGL-devel \
     mesa-libGLU-devel glew-devel mysql-devel fftw-devel graphviz-devel \
     avahi-compat-libdns_sd-devel python-devel libxml2-devel gls-devel blas-devel \
     bazel http-parser nodejs perl-Digest-MD5 zlib-devel perl-ExtUtils-MakeMaker gettext \
     libffi-devel pandoc texlive texlive-collection-xetex texlive-ec texlive-upquote \
     texlive-adjustbox emacs bzip2 zip unzip lrzip tree ack screen tmux vim-enhanced emacs-nox \
     libarchive-devel fuse-sshfs jq graphviz \
     && yum clean all

## install cmake 3.12 (required to build ROOT 6)
RUN sudo yum remove cmake #removes cmake command conflict
RUN wget --quiet https://cmake.org/files/v3.12/cmake-3.12.0-rc3.tar.gz -O /tmp/cmake.tar.gz && \
    tar -zxf /tmp/cmake.tar.gz --directory=/tmp  && cd /tmp/cmake-3.12.0-rc3/ && \
    ./bootstrap && \
    make -j 4  && sudo make install && \
    rm -r /tmp/cmake.tar.gz /tmp/cmake-3.12.0-rc3 
    #echo "alias cmake12='/packages/cmake-3.12.0-rc3/cmake '$@''" >> /root/.bashrc

## build boost 1.67 (this version required by scdmsPyTools, not packaged in centos)
RUN ln -s /opt/rh/rh-python36/root/usr/include/python3.6m /opt/rh/rh-python36/root/usr/include/python3.6
RUN source scl_source enable rh-python36 && \
    wget --quiet https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz -O ~/boost.tar.gz && \
    tar -zxf ~/boost.tar.gz --directory=$HOME && \
    cd ~/boost_1_67_0/ && \
    ./bootstrap.sh && \
    ./b2 install --prefix=/packages/boost1.67 -j 4

## install ROOT 6.12
RUN wget --quiet https://root.cern.ch/download/root_v6.12.06.source.tar.gz -O ~/rootsource.tar.gz && \
    tar -zxf ~/rootsource.tar.gz --directory=$HOME
RUN source scl_source enable rh-python36 && \
    mkdir -p $HOME/root-6.12.06/rootbuild && cd $HOME/root-6.12.06/rootbuild && \
    cmake -j 4 \
    -Dxml:BOOL=ON \
    -Dvdt:BOOL=OFF \
    -Dbuiltin_fftw3:BOOL=ON \
    -Dfitsio:BOOL=OFF \
    -Dfftw:BOOL=ON \
    -Dxrootd:BOOL=OFF \
    -DCMAKE_INSTALL_PREFIX:PATH=/packages/root6.12 \
    -Dpython3=ON \
    -Dpython=ON \
    -DPYTHON_EXECUTABLE:PATH=/opt/rh/rh-python36/root/usr/bin/python \
    -DPYTHON_INCLUDE_DIR:PATH=/opt/rh/rh-python36/root/usr/include/python3.6m \
    -DPYTHON_LIBRARY:PATH=/opt/rh/rh-python36/root/usr/lib64/libpython3.6m.so \
    ..  
RUN source $HOME/root-6.12.06/rootbuild/bin/thisroot.sh && \
    cd $HOME/root-6.12.06/rootbuild && \
    cmake --build . --target install -- -j4
RUN rm -r ~/rootsource.tar.gz ~/root-6.12.06

## Create softlink for boost shared objects (for compatibility) 
RUN ln -s /packages/boost1.67/lib/libboost_numpy36.so /packages/boost1.67/lib/libboost_numpy.so && \
    ln -s /packages/boost1.67/lib/libboost_python36.so /packages/boost1.67/lib/libboost_python.so

## Install additional Python modules
RUN source /packages/root6.12/bin/thisroot.sh && \
    source scl_source enable rh-python36 && \
    pip3 --no-cache-dir install \
    root_numpy \
    uproot \
    h5py \
    iminuit \
    tensorflow \ 
    pydot \
    keras
     

## Install scdmsPyTools    
WORKDIR /packages
RUN export BOOST_PATH=/packages/boost1.67 && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/packages/boost1.67/lib && \
    source /packages/root6.12/bin/thisroot.sh && \
    source scl_source enable rh-python36 && \
    cd scdmsPyTools/scdmsPyTools/BatTools && \
    make && \
    cd ../.. && \
    python setup.py install

## Install pyCAP
WORKDIR /packages/pyCAP
RUN source scl_source enable rh-python36 && \
    python setup.py install

## Copy post-hook for moving Tutorials dir 
COPY hooks/copy-tutorials.sh /opt/slac/jupyterlab/post-hook.sh
COPY hooks/launch.bash-with-root /opt/slac/jupyterlab/launch.bash