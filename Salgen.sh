
rm -rf ./Tpmapgen/tmp
mkdir ./Tpmapgen/tmp

matlab -nodesktop -nosplash -r Tpmapgen.m

python Salpredict.py

rm -rf ./Tpmapgen/tmp

