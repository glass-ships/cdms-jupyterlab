#!/bin/bash
cd $HOME/Downloads
wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz
tar -zxf boost_1_67_0.tar.gz
cd boost_1_67_0/
./bootstrap.sh
./b2 install --prefix=$HOME/packages/boost1.67
