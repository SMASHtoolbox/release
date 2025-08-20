% REPLACE Replace data values in an object
%
% This method replaces a rectangular region in one Image of an ImageGroup 
% with a specified value.  The replacement value *must* be specified; the 
% replacement region can be specified or selected interactively.
%
% To replace values in a specific region:
%     >> object=replace(object,imageNumber,value,[xA xB],[yA yB]);
% where xA, xB, yA, and yB are bounding grid values.  When no bounding
% region is specified:
%     >> object=replace(object,imageNumber,value);
% the user is prompted to select the region.
%
% see also ImageGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

function object=replace(object,imageNumber,value,varargin)

% handle input
assert(nargin>=3,'Invalid number of inputs');
assert(rem(imageNumber,1)==0,'Image selection must be an integer');

% split up ImageGroup
temp=cell(object.NumberImages,1);

% Perform function on each image individually
[temp{:}]=split(object);

    temp{imageNumber}=replace(temp{imageNumber},value,varargin{:});

% remake ImageGroup
object=SMASH.ImageAnalysis.ImageGroup(temp{:});


end

