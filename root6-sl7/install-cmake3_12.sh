sudo yum remove cmake
wget --quiet https://cmake.org/files/v3.12/cmake-3.12.0-rc3.tar.gz -O ~/cmake.tar.gz
tar -zxf ~/cmake.tar.gz --directory=$HOME
cd $HOME/cmake-3.12.0-rc3/ 
./bootstrap 
make && sudo make install 
rm -r ~/cmake.tar.gz ~/cmake-3.12.0-rc3
