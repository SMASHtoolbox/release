function [ object,xypath ] = align( object,varargin )
%ALIGN Align ImageGroup objects
%
%   Under Construction*
% This method aligns an ImageGroup object using a set of specified set of
% (x,y) points.  The best fit polynomial through these points becomes a
% fixed grid path.  
%
% Usage:
%   >> object=align(object,direction,xypath,order);
%    - direction...
%    -xypath should be table of [x y] values 
%    -order is the polynomial order used to define the alignment boundary
%    (default is 1).
% Users will be prompted to select the xypath if input table is omitted.
%
% *If no inputs are provided, the user is prompted to select inputs for
% each Image within the ImageGroup (and each Image has a separate align
% process performed based on those individual selections).
%
% see also ImageGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

temp=cell(object.NumberImages,1);
output=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);
for n=1:object.NumberImages
    [tempObj{n},output{n}]=align(temp{n},varargin{:});
end

object=SMASH.ImageAnalysis.ImageGroup(tempObj{:});

xypath = output{:};

end

