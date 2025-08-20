% SHIFT Shifts an ImageGroup object by a scalar value
%
% Usage:
%   >> object=shift(object,coordinate,value)
% The "coordinate" input may be 'Grid1' or 'Grid2'.
%
% See also ImageGroup, map, scale

% created February 11, 2016 by Sean Grant (Sandia National Laboratories/UT)

function object=shift(object,coordinate,value)

% split up ImageGroup
temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    tempObj{n}=shift(temp{n},coordinate,value);
end

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});


end

