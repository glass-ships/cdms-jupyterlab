################################################################################
####     Dockerfile for creation of SuperCDMS JupyterLab analysis image     ####   
####     See ./README.md for details                                        ####
################################################################################

FROM slaclab/slac-jupyterlab:20190712.2
USER root

### ROOT and Boost ###
RUN yum -y install sudo && sudo yum -y upgrade
# ROOT and Boost dependencies
RUN sudo yum install -y gcc-gfortran openssl-devel pcre-devel \
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

### Extra packages and CDMS dependencies ###

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
	fish tree ack screen tmux vim-enhanced neovim nano pico emacs emacs-nox \  
	&& sudo yum clean all

## Install additional Python packages
RUN source /packages/root6.12/bin/thisroot.sh && \
	source scl_source enable rh-python36 && \
	pip3 install --upgrade pip setuptools && \
	pip3 --no-cache-dir install \
		jupyter jupyterlab metakernel \
		memory-profiler \
		root_numpy root_pandas uproot \
		h5py tables \
		iminuit tensorflow pydot keras \
		awkward awkward-numba zmq \
		dask[complete] \
		xlrd xlwt openpyxl 

## Install Anaconda 3
RUN wget --quiet https://repo.anaconda.com/archive/Anaconda3-2019.03-Linux-x86_64.sh -O /packages/anaconda.sh && \
    /bin/bash /packages/anaconda.sh -b -p /packages/anaconda3 && \
    rm /packages/anaconda.sh
COPY scripts/rootenv.sh /packages/root6.12/bin/ 
RUN . /packages/anaconda3/etc/profile.d/conda.sh && \
	conda activate base && \ 
	. /packages/root6.12/bin/rootenv.sh && \
	conda install jupyter jupyterlab metakernel \
	        h5py iminuit tensorflow pydot keras \
	        dask[complete] \
	        xlrd xlwt openpyxl && \
	pip install --upgrade pip setuptools && \
	pip --no-cache-dir install memory-profiler tables \
		zmq root_pandas awkward awkward-numba uproot root_numpy

### CDMS packages ###

## Import CDMS packages
COPY cdms_repos/python_colorschemes /packages/python_colorschemes
COPY cdms_repos/tutorials /packages/tutorials
COPY cdms_repos/analysis_tools /packages/analysis_tools
COPY cdms_repos/pyCAP /packages/pyCAP
COPY cdms_repos/scdmsPyTools /packages/scdmsPyTools
COPY cdms_repos/scdmsPyTools_TF /packages/scdmsPyTools_TF
COPY cdms_repos/bash_env /packages/bash_env

WORKDIR /packages
RUN source scl_source enable rh-python36 && \
	source /packages/root6.12/bin/thisroot.sh && \
	export BOOST_PATH=/packages/boost1.67 && \
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/packages/boost1.67/lib && \
	cd scdmsPyTools/scdmsPyTools/BatTools && \
	make && \
	cd ../.. && \
	python setup.py install && \
	cd /packages/pyCAP && \
	python setup.py install && \
	cd /packages/analysis_tools && \
	python setup.py install && \
	cd /packages/python_colorschemes && \
	python setup.py install

### Finalize environment ###

## Copy hook for Tutorials and custom bash env
COPY hooks/post-hook.sh /opt/slac/jupyterlab/post-hook.sh

## Create ROOT-enabled and code-developing notebook options 
COPY hooks/launch.bash /opt/slac/jupyterlab/launch.bash
COPY kernels/py3-ROOT /opt/rh/rh-python36/root/usr/share/jupyter/kernels/python3/kernel.json
RUN rm -rf /usr/local/share/jupyter/kernels/slac_stack
