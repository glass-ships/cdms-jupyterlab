#!/bin/bash

trap exit INT TERM QUIT ERR

# just in case 
alias rebuild-root="cd $HOME/Downloads && rm -rf root-6.12.06/ $HOME/packages/root6.12 && tar -zxf root_v6.12.06.source.tar.gz"

# download and unpack root6.12.06 source code
cd $HOME/Downloads
wget https://root.cern.ch/download/root_v6.12.06.source.tar.gz 
tar -xzf root_v6.12.06.source.tar.gz

# enable root to use anaconda3
cd $HOME/Downloads/root-6.12.06
./configure --enable-python --with-python=$CONDA_PREFIX/bin/python3.6 --with-python-incdir=$CONDA_PREFIX/include/python3.6m --with-python-libdir=$CONDA_PREFIX/lib --all

# create and move to new ROOT build dir
mkdir -p $HOME/Downloads/rootbuild
cd $HOME/Downloads/rootbuild

# build and install ROOT
cmake -Dxml:BOOL=ON -Dvdt:BOOL=OFF -Dbuiltin_fftw3:BOOL=ON -Dfitsio:BOOL=OFF -Dfftw:BOOL=ON -Dxrootd:BOOL=OFF  -DCMAKE_INSTALL_PREFIX=~/packages/root6.12 ~/Downloads/root-6.12.06
source $HOME/Downloads/rootbuild/bin/thisroot.sh
cmake --build . --target install -- -j4
