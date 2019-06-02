#!/bin/bash

rm -f ./Tpmapgen/tmp
mkdir ./Tpmapgen/tmp

matlab -nodesktop -nosplash -r Tpmapgen.m

python Salpredict.py

rm -f ./Tpmapgen/tmp

