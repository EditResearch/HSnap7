#!/bin/sh


sudo cp -v lib/Linux/libsnap7.so /usr/lib64
sudo cp -v lib/snap7.h /usr/include/

sudo ldconfig
