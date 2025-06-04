% REGRID Transfer ImageGroup object onto a new grid
%
% This method interpolates an existing object into a new object on a
% specified grid.
%    >> new=regrid(object,x,y);
% If no grid is specified, a uniformly spaced grid is calculated from the
% existing grid.
%    >> object=regrid(object);
% This technique may needed before using methods requiring a uniformly
% spaced grid (such as fft).
%
% See also ImageGroup, lookup
%

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

function object=regrid(object,x,y)

% handle input
if (nargin<2)
    x=[];
end

if nargin<3
    y=[];
end

% split up ImageGroup
temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    tempObj{n}=regrid(temp{n},x,y);
end

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});


end

