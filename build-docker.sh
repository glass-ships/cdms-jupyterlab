#!/bin/bash

## Clone CDMS repositories locally

git clone josh@nero:/data/git/Analysis/scdmsPyTools.git
cd scdmsPyTools/scdmsPyTools/BatTools
rm -rf BatCommon
git clone josh@nero:/data/git/Reconstruction/BatCommon.git
cd BatCommon
rm -rf IOLibrary
git clone josh@nero:/data/git/DAQ/IOLibrary
cd ../../..
git checkout master
git submodule update --init --recursive 

cd ..
git clone josh@nero:/data/git/Analysis/pyCAP.git

git clone josh@nero:/data/git/Analysis/tutorials.git

git clone josh@nero:/data/git/Analysis/python_colorschemes.git

git clone josh@nero:/data/git/TF_Analysis/Northwestern/analysis_tools.git

docker build \
    -t "$2" # detlab/cdms-jupyterlab:0.1.0 \
    --rm \
    -f Dockerfile .
