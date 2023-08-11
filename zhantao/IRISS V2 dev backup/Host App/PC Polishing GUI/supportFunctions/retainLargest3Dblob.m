function pcloud = retainLargest3Dblob(pcloud)
%RETAINLARGEST3DBLOB 2021-11-01 MJG 
%   Writing code on my birthday... how sad =(
%   Does what the function name suggests: retains the largest 3D blob from
%   a 3D binary point cloud 

    % find all volumes 
    props = regionprops3(pcloud, 'Volume'); 
    % sort the volumes by size 
    sortedVolumes = sort([props.Volume], 'descend');
    % retain largest ... 
    pcloud = bwareaopen(pcloud, sortedVolumes(1));

end