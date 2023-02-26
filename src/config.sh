#!/bin/bash
#######################################################################################
#author: SH
#date: 2022/02/24
#describe: A config-script
#bash src/config.sh
#######################################################################################
echo "installing harc compressor..."
git config --global http.postBuffer 11024288000
git clone https://github.com/shubhamchandak94/HARC.git #--config "http.proxy=127.0.0.1:7890"
if [ $? -ne 0 ]; then
    echo "clone harc project wrong!"
    exit 0
fi
cd HARC
chmod +x ./install.sh
./install.sh
if [ $? -ne 0 ]; then
    echo "install harc project wrong!"
    exit 0
fi
echo "installing harc compressor successfuly..."

echo "installing spring compressor..."
git clone https://github.com/shubhamchandak94/Spring.git #--config "http.proxy=127.0.0.1:7890"
if [ $? -ne 0 ]; then
    echo "clone spring project wrong!"
    exit 0
fi
cd Spring
mkdir build
cd build
cmake ..
make
if [ $? -ne 0 ]; then
    echo "install spring project wrong!"
    exit 0
fi
echo "installing spring compressor successfuly..."


echo "installing mstcom compressor..."
### configure C compiler
export compiler=$(which gcc)

### get version code
MAJOR=$(echo __GNUC__ | $compiler -E -xc - | tail -n 1)
MINOR=$(echo __GNUC_MINOR__ | $compiler -E -xc - | tail -n 1)
PATCHLEVEL=$(echo __GNUC_PATCHLEVEL__ | $compiler -E -xc - | tail -n 1)
if [ ${MAJOR} -gt 7 ] && [ ${MAJOR} ]; then
  echo "gcc version: ${MAJOR}.${MINOR}.${PATCHLEVEL}"
else
  echo "gcc -version must great than 8.4.0..."
  echo "yours: ${MAJOR}.${MINOR}.${PATCHLEVEL}"
  exit 0
fi

#module load compiler/gnu/gcc-compiler-8.4.0
git clone https://github.com/yuansliu/mstcom.git #--config "http.proxy=127.0.0.1:7890"
if [ $? -ne 0 ]; then
    echo "clone mstcom project wrong!"
    exit 0
fi
cd mstcom
make
if [ $? -ne 0 ]; then
    echo "install mstcom project wrong!"
    exit 0
fi
echo "installing mstcom compressor successfuly..."