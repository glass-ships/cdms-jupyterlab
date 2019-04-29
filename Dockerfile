################################################################################
####     Dockerfile for creation of SuperCDMS JupyterLab analysis image     ####   
####     See ./README.md for details                                        ####
################################################################################

#### intermediate image

FROM centos:7 as intermediate
USER root

## install git
RUN yum -y upgrade
RUN yum -y install sudo
RUN sudo yum install -y git

## supply credentials
ARG SSHKEYPUB
ARG SSHKEYPVT
ARG SSHHOSTS
ARG SSHCONFIG

RUN mkdir /root/.ssh && \
	echo "$SSHKEYPUB" > /root/.ssh/id_rsa.pub && \
	echo "$SSHKEYPVT" > /root/.ssh/id_rsa && \
	echo "$SSHHOSTS" > /root/.ssh/known_hosts && \
	echo "$SSHCONFIG" > /root/.ssh/config

RUN sudo chmod 600 /root/.ssh/config && \
	sudo chmod 600 /root/.ssh/id_rsa && \
	sudo chmod 644 /root/.ssh/known_hosts

## clone cdms repos
WORKDIR /packages
#RUN git clone --recursive josh@nero:/data/git/Analysis/scdmsPyTools.git && \
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
RUN cd /packages && \ 
	git clone josh@nero:/data/git/Analysis/pyCAP.git && \
	git clone josh@nero:/data/git/Analysis/tutorials.git && \
	git clone josh@nero:/data/git/Analysis/python_colorschemes.git && \ 
	git clone josh@nero:/data/git/TF_Analysis/Northwestern/analysis_tools.git

##################################################################################

#### final image

FROM slaclab/slac-jupyterlab-gpu:20190106.0 
USER root

### pull repos from intermediate build
COPY --from=intermediate /packages/ /packages/

### ROOT and Boost ###

# ROOT and Boost dependencies
RUN sudo yum -y upgrade && \
	sudo yum install -y gcc-gfortran openssl-devel pcre-devel \
	mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel \
	fftw-devel cfitsio-devel graphviz-devel gsl-static\
	avahi-compat-libdns_sd-devel libldap-dev python-devel \
	libxml2-devel libXpm-devel libXft-devel gcc-c++ 

# install cmake 3.12 (required to build ROOT 6)
RUN wget --quiet https://cmake.org/files/v3.12/cmake-3.12.0-rc3.tar.gz -O /tmp/cmake.tar.gz && \
	tar -zxf /tmp/cmake.tar.gz --directory=/tmp  && cd /tmp/cmake-3.12.0-rc3/ && \
	./bootstrap && \
	make -j 4  && sudo make install && \
	rm -r /tmp/cmake.tar.gz /tmp/cmake-3.12.0-rc3 

# build boost 1.67 (this version required by scdmsPyTools, not packaged in centos)
RUN sudo ln -s /opt/rh/rh-python36/root/usr/include/python3.6m /opt/rh/rh-python36/root/usr/include/python3.6
RUN source scl_source enable rh-python36 && \
	wget --quiet https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz -O ~/boost.tar.gz && \
	tar -zxf ~/boost.tar.gz --directory=$HOME && \
	cd ~/boost_1_67_0/ && \
	./bootstrap.sh && \
	./b2 install --prefix=/packages/boost1.67 -j 4

# compile ROOT 6.12
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

### ###
## Install additional system packages
RUN sudo yum install -y \
	centos-release-scl git patch net-tools binutils \
	gcc libcurl-devel libX11-devel \
	blas-devel libarchive-devel fuse-sshfs jq graphviz dvipng \
	libXext-devel bazel http-parser nodejs perl-Digest-MD5 perl-ExtUtils-MakeMaker gettext \
	# LaTeX tools
	pandoc texlive texlive-collection-xetex texlive-ec texlive-upquote texlive-adjustbox \ 
	# Data formats
	hdf5-devel \ 
	# Compression tools
	bzip2 unzip lrzip zip zlib-devel \ 
	# Terminal utilities
	tree ack screen tmux vim-enhanced vim-nox emacs emacs-nox \  
	&& sudo yum clean all
	
## Install additional Python packages
RUN source /packages/root6.12/bin/thisroot.sh && \
	source scl_source enable rh-python36 && \
	pip3 install --upgrade pip && \
	pip3 --no-cache-dir install \
		jupyter jupyterlab metakernel \
		root_numpy uproot \
		h5py tables \
		iminuit tensorflow pydot keras \
		awkward-numba zmq \
		dask[complete] \
		xlrd xlwt openpyxl 
     
### CDMS packages ###
WORKDIR /packages/scdmsPyTools
RUN export BOOST_PATH=/packages/boost1.67 && \
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/packages/boost1.67/lib && \
	source /packages/root6.12/bin/thisroot.sh && \
	source scl_source enable rh-python36 && \
	cd scdmsPyTools/BatTools && \
	make && \
	cd ../.. && \
	python setup.py install

WORKDIR /packages/pyCAP
RUN source scl_source enable rh-python36 && \
	python setup.py install

WORKDIR /packages/analysis_tools
RUN source scl_source enable rh-python36 && \ 
	python setup.py install

WORKDIR /packages/python_colorschemes
RUN source scl_source enable rh-python36 && \
	python setup.py install

### Finalize environment ###
## Copy hook to create/manage tutorials directory in user's home
COPY hooks/copy-tutorials.sh /opt/slac/jupyterlab/post-hook.sh

## Copy update launch.bash to source ROOT in jupyter python notebooks 
COPY hooks/launch.bash-with-root /opt/slac/jupyterlab/launch.bash

## Rename SLAC_Stack jupyter kernel
COPY kernels/rename-slac-stack /usr/local/share/jupyter/kernels/slac_stack/kernel.json 

## allow arrow key navigation in terminal vim
RUN echo 'set term=builtin_ansi' >> /etc/vimrc
