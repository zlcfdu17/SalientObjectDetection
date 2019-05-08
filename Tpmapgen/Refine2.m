function [ SM_refined ] = Refine2( IM_origin, SM_coarsed, IM_seg )
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明

THRESH = 0.5;

[labels, numlabels] = slicmex(IM_origin, 200, 20);
[LEN,WID] = size(IM_origin(:,:,1));
SM_c = double(imresize(SM_coarsed,[LEN WID]));
Seg = double(imresize(IM_seg,[LEN WID]));
SM_refined = zeros(LEN,WID);

for ii = 1:numlabels 
    mask = (labels==ii);
    spp_size = sum(sum(mask));
    spp_sum = sum(sum(mask.*SM_c));
    spp_avg = spp_sum/spp_size;
    if spp_avg>THRESH
        SM_refined = SM_refined + spp_avg*mask;
        
    end
end

SM_refined = uint8(SM_refined);




end

