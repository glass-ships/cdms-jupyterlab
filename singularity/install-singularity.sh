#!/usr/bin/env bash

### Dependencies 

sudo yum update && \
	sudo yum groupinstall 'Development Tools' && \
	sudo yum install libarchive-devel libuuid-devel



# Install GoLang from source

export VERSION=1.11 OS=linux ARCH=amd64
cd /tmp
wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz
sudo tar -C /usr/local -xzf go$VERSION.$OS-$ARCH.tar.gz

echo 'export GOPATH=${HOME}/go' >> ~/.bashrc
echo 'export PATH=/usr/local/go/bin:${PATH}:${GOPATH}/bin' >> ~/.bashrc
source ~/.bashrc

# Install go dependencies
go get -u -v github.com/golang/dep/cmd/dep

### 

### Clone and compile singularity

mkdir -p $GOPATH/src/github.com/sylabs
cd $GOPATH/src/github.com/sylabs
git clone https://github.com/sylabs/singularity.git
cd singularity

cd $GOPATH/src/github.com/sylabs/singularity
./mconfig
make -C builddir
sudo make -C builddir install
