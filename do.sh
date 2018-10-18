#!/bin/bash
mkdir build
cd build
cmake -DBOOST_INCLUDEDIR=$BOOST_I -DBOOST_LIBRARYDIR=$BOOST_L ..
make
mv $HOME/mkxpplus/build/mkxp.binx86 ..
mv $HOME/mkxpplus/build/mkxp.binx64 ..