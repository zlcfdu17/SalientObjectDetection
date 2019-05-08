clear all;

ImgPath = ' ';
SegPath = ' ';
ims = dir(fullfile(ImgPath,'*.jpg*'));

sigma = 0.5;
k = 500;
mim_z = 20;
for ii = 1:length(ims)
   img = imread(fullfile(ImgPath,ims(ii).name));
   seg = pfsegment(img,sigma,k,mim_z);
   labels = SegmentToLabels(rgb2gray(seg));
   pf = zeros(size(labels));
   
   numlabels = max(max(labels));
   color = zeros(numlabels,3);
   R = zeros(1,numlabels);
   for jj = 1:numlabels
       temp = img(:,:,1);
       color(jj,1) = mean(temp(labels==jj));
       temp = img(:,:,2);
       color(jj,2) = mean(temp(labels==jj));       
       temp = img(:,:,3);              
       color(jj,3) = mean(temp(labels==jj));
       
%        R(jj) = sum(sum( (labels==jj) ));
       
   end
   
   D = sum(dist(color,color'));
%    W = R.*D;
   W = D/max(D);
   
   for jj = 1:numlabels
        pf = pf + (labels==jj)*W(jj);   
   end
   res = uint8(pf*255);
%    figure(); imshow(res);
   res_rf = Refine2(img,res,res);

   name = strrep(ims(ii).name,'.jpg','.png');
   imwrite(res_rf,fullfile(SegPath,name));
   if ~mod(ii,100)
       fprintf('%d / %d is processed.\n', ii, length(ims))
   end
end
