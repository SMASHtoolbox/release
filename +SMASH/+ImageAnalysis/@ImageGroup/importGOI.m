% IMPORTGOI read GOI/SEGOI hdf images
%
% This static method outputs an ImageGroup object from a GOI/SEGOI hdf file 
% and orders the images sequentially by frame.
%
% Usage:
%   >> object=SMASH.ImageAnalysis.ImageGroup.importGOI(filename)
%
% Created by Nathan Brown (SNL) 07/2025

function object = importGOI(filename)
data = [];
for ii = 1:8
    data = cat(3,data,hdfread(filename, sprintf('DS%d',ii)));
end
data(:,:,[1 4]) = data(:,:,[4 1]); % swap 1 and 4
data(:,:,[2 3]) = data(:,:,[3 2]); % swap 2 and 3

object = SMASH.ImageAnalysis.ImageGroup(1:size(data,2),1:size(data,1),data);
object.Legend = strrep(object.Legend, 'image', 'Frame');
object.GraphicOptions.ColorMap = 'gray';
object.GraphicOptions.AspectRatio = 'equal';
end