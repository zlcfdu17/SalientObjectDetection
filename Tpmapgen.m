clear all;

addpath('Tpmapgen','Tpmapgen/PF_segmentation','Tpmapgen/SLIC_mex')

if ~exist('pfsegment', 'file')
    cd ./Tpmapgen/PF_segmentation
    mex -DMEX pfsegment.cpp
    cd ../
    cd ../
end

if ~exist('slicmex', 'file')
    cd ./Tpmapgen/SLIC_mex
    mex slicmex.c
    cd ../
    cd ../
end

ImgPath = '.\Img';
SegPath = '.\Tpmapgen\tpmap';
ims = dir(fullfile(ImgPath,'*.jpg*'));

sigma = 0.5;
k = 500;
mim_z = 20;
fprintf('generating topological maps...\n');
h = waitbar( 0, 'generating topological maps...');
for ii = 1:length(ims)
   str = ['generating topological maps...',num2str(ii/length(ims)*100),'%'];
   waitbar(ii/length(ims), h, str);
   img = imread(fullfile(ImgPath,ims(ii).name));
   seg = pfsegment(img,sigma,k,mim_z);
   labels = SegmentToLabels(rgb2gray(seg));
   pf = zeros(size(labels));
   
   img_lab = RGB2Lab(img);
   
   numlabels = max(max(labels));
   color = zeros(numlabels,3);
   space = zeros(numlabels,2);
   numpix = zeros(numlabels,1);
   center = zeros(numlabels,1);
   
   for jj = 1:numlabels
       temp = img_lab(:,:,1);
       color(jj,1) = mean(temp(labels==jj));
       temp = img_lab(:,:,2);
       color(jj,2) = mean(temp(labels==jj));
       temp = img_lab(:,:,3);
       color(jj,3) = mean(temp(labels==jj));
       
       [row, col] = find(labels==jj);
       space(jj,1) = mean(col)/500;
       space(jj,2) = mean(row)/500;
       center(jj) = mean(dist([col row]/500,[0.5 0.5]'));
       
       numpix(jj) = sum(sum( (labels==jj) ));
       
   end
   
   D = sum(dist(color,color'));
   S = exp(-sum(dist(space,space'))/200);
   C = exp(-1/0.2*center.^2);
   
   W = D.*S.*C';
   W = W/max(W);
   
   for jj = 1:numlabels
        pf = pf + (labels==jj)*W(jj);   
   end
   res = uint8(pf*255);
%    figure(); imshow(res);
   res_rf = Refine2(img,res,res);

   name = strrep(ims(ii).name,'.jpg','.png');
   imwrite(res_rf,fullfile(SegPath,name));
%    if ~mod(ii,length(ims)/10)
%        fprintf('%d / %d is processed.\n', ii, length(ims))
%    end
end

delete(h)

