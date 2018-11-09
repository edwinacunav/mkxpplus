#!/bin/bash
mkdir build
cd build
cmake -DBOOST_INCLUDEDIR=$BOOST_I -DBOOST_LIBRARYDIR=$BOOST_L ..
make
echo "Moving binary executable to project's root directory..."
mv $HOME/mkxpplus/build/mkxpplus.bin* ..
echo "Stripping binary executable now..."
if [ -f mkxpplus.binx64 ]; then
  strip mkxpplus.binx64
else
  strip mkxpplus.bin
if
