#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo Script directory: $DIR

## Clone CDMS repositories locally

if [ ! -e "$DIR/cdms_repos" ]; then
	mkdir  -p "$DIR/cdms_repos"
	cd $DIR/cdms_repos

	git clone --recursive josh@nero:/data/git/Analysis/scdmsPyTools.git
	git clone josh@nero:/data/git/Analysis/pyCAP.git
	git clone josh@nero:/data/git/Analysis/tutorials.git
	git clone josh@nero:/data/git/Analysis/python_colorschemes.git
	git clone josh@nero:/data/git/TF_Analysis/Northwestern/analysis_tools.git
	git clone josh@nero:/data/git/Analysis/TWaveform-casa.git

elif [ -d "$DIR/cdms_repos" ]; then
	
	cd $DIR/cdms_repos/scdmsPyTools && git pull
	cd ../pyCAP && git pull
	cd ../tutorials && git pull
	cd ../python_colorschemes && git pull
	cd ../analysis_tools && git pull
fi

## Build Docker image

cd $DIR
docker build \
    --rm \
    -f Dockerfile .
