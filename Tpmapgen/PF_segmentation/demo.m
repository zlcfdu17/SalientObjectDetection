clear all;
close all;
clc;

if ~exist('pfsegment', 'file')
    mex -DMEX pfsegment.cpp
end

ImgPath = ' ';
SegPath = ' ';
ims = dir(fullfile(ImgPath,'*.jpg*'));

sigma = 0.5;
k = 650;
mim_z = 20;

for ii = 1:length(ims)
   img = imread(fullfile(ImgPath,ims(ii).name));
   seg = pfsegment(img,sigma,k,mim_z);
   
   imwrite(seg,fullfile(SegPath,ims(ii).name));
    
   if ~mod(ii,100)
       fprintf('%d / %d is processed.\n', ii, length(ims))
   end
end


