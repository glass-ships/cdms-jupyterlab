#!/bin/bash
cd $HOME/Downloads
wget https://repo.anaconda.com/archive/Anaconda3-5.2.0-Linux-x86_64.sh
bash Anaconda3-5.2.0-Linux-x86_64.sh
echo "export CONDA_PREFIX=$HOME/packages/anaconda3" >> ~/.bashrc
echo "export PATH=$CONDA_PREFIX/bin:$PATH" >> ~/.bashrc
source $HOME/.bashrc
