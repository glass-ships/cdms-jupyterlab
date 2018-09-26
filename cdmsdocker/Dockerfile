##########################################################################################
# Dockerfile for creation of a SuperCDMS analysis suite image
# Jupyterhub support incoming 
##########################################################################################

#### intermediate image 
FROM centos:7 

## install git
RUN yum -y upgrade
RUN yum install -y git

## supply credentials
ARG SSHKEYPUB
ARG SSHKEYPVT
RUN mkdir /root/.ssh && \
    echo "$SSHKEYPUB" > /root/.ssh/id_rsa.pub && \
    echo "$SSHKEYPVT" > /root/.ssh/id_rsa
   
COPY ssh-config /root/.ssh/config
RUN chmod 600 /root/.ssh/config
RUN touch /root/.ssh/known_hosts && \
    ssh-keyscan -t rsa nero.stanford.edu >> ~/.ssh/known_hosts

## clone cdms repos
WORKDIR /packages
RUN git clone --recursive josh@nero:/data/git/Analysis/scdmsPyTools.git && \ 
    cd scdmsPyTools && git submodule update --init --recursive
RUN git clone josh@nero:/data/git/Analysis/pyCAP.git

##########################################################################################

#### build image 
FROM centos:7

## pull repos from intermediate build
COPY --from=0 /packages/pyCAP/ /packages/pyCAP 
COPY --from=0 /packages/scdmsPyTools/packages/scdmsPyTools

USER root

## update base packages, enable epel repo
RUN  yum install -y epel-release
RUN  yum repolist
RUN  yum -y upgrade

## install various packages and dependencies 
RUN  yum install -y nodejs libcurl-devel mysql-devel net-tools sudo centos-release-scl \
     make wget git patch gcc-c++ gcc binutils libX11-devel libXpm-devel libXft-devel \
     libXext-devel gcc-gfortran openssl-devel pcre-devel mesa-libGL-devel \
     mesa-libGLU-devel glew-devel mysql-devel fftw-devel graphviz-devel \
     avahi-compat-libdns_sd-devel python-devel libxml2-devel gls-devel blas-devel \ 
     bazel http-parser nodejs perl-Digest-MD5 zlib-devel perl-ExtUtils-MakeMaker gettext \
     libffi-devel pandoc texlive texlive-collection-xetex texlive-ec texlive-upquote \
     texlive-adjustbox emacs bzip2 zip unzip lrzip tree ack screen tmux vim-enhanced emacs-nox \
     libarchive-devel fuse-sshfs jq \
     && yum clean all

## configure python3 & modules (slac-jupyterhub method)
RUN  yum -y install centos-release-scl && \
     yum-config-manager --enable rhel-server-rhscl-7-rpms && \
     yum -y install rh-git29 devtoolset-6 rh-python36-python-tkinter \
     rh-python36 rh-python36-python-devel rh-python36-python-setuptools-36 \
     rh-python36-PyYAML \
     && yum clean all
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade pip setuptools==39.1.0 wheel
RUN  source scl_source enable rh-python36 && \
      pip3  --no-cache-dir  install --upgrade \
        virtualenv virtualenvwrapper ipykernel pipenv numpy scipy pandas matplotlib \
        ipywidgets mat4py gsutil scikit-image pygments nbdime\
        nbval pypandoc rise bokeh seaborn wordcloud textblob \
        nltk kaggle h5py mat4py gsutil zmq humanize tqdm cython \
        gputil psutil scikit-image Pillow opencv-python scikit-learn \
        tensorflow-gpu tensorboard keras torch torchvision

## install cmake 3.12 (required to build ROOT 6)
RUN sudo yum remove cmake #removes cmake command conflict
RUN wget --quiet https://cmake.org/files/v3.12/cmake-3.12.0-rc3.tar.gz -O ~/cmake.tar.gz && \
    tar -zxf ~/cmake.tar.gz --directory=$HOME  && cd $HOME/cmake-3.12.0-rc3/ && \
    ./bootstrap && \
    make && sudo make install && \
    rm -r ~/cmake.tar.gz ~/cmake-3.12.0-rc3

## build boost 1.67 (this version required by scdmsPyTools, not packaged in centos)
RUN wget --quiet https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz -O ~/boost.tar.gz && \
    tar -zxf ~/boost.tar.gz --directory=$HOME && \
    cd ~/boost_1_67_0/ && \
    ./bootstrap.sh && \
    ./b2 install --prefix=/packages/boost1.67

## install ROOT 6.12
ENV PYTHONDIR=/opt/rh/rh-python36/root/usr/bin
RUN wget --quiet https://root.cern.ch/download/root_v6.12.06.source.tar.gz -O ~/rootsource.tar.gz && \
    tar -zxf ~/rootsource.tar.gz --directory=$HOME
RUN source scl_source enable rh-python36 && \
    mkdir -p $HOME/root-6.12.06/rootbuild && cd $HOME/root-6.12.06/rootbuild && \
    cmake \
    -Dxml:BOOL=ON \
    -Dvdt:BOOL=OFF \
    -Dbuiltin_fftw3:BOOL=ON \
    -Dfitsio:BOOL=OFF \
    -Dfftw:BOOL=ON \
    -Dxrootd:BOOL=OFF \
    -DCMAKE_INSTALL_PREFIX=/packages/root6.12 \
    -DPYTHON_EXECUTABLE=$PYTHONDIR/python \
    -DPYTHON_INCLUDE=$PYTHONDIR/include \
    ..
RUN source $HOME/root-6.12.06/rootbuild/bin/thisroot.sh && \
    cd $HOME/root-6.12.06/rootbuild && \
    cmake --build . --target install
RUN rm -r ~/rootsource.tar.gz ~/root-6.12.06

## install scdmsPyTools
ENV BOOST_PATH=/packages/boost1.67
WORKDIR /packages
RUN source scl_source enable rh-python36 && \
    cd scdmsPyTools/scdmsPyTools/BatTools && \
    make  && \
    cd ../.. && \
    python setup.py install
    
## setup pyCAP
WORKDIR /packages/pyCAP
RUN source scl_source enable rh-python36 && \
    python setup.py install
