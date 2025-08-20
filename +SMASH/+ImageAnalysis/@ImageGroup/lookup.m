% LOOKUP Look up data values at specific grid locations
%
% This method returns interpolated data values for specified grid
% locations.
%    >> z=lookup(object,x,y);
%
% See also ImageGroup, regrid
% 

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified for ImageGroup February 11, 2016 by Sean Grant (SNL/UT)
%
function z=lookup(object,x,y)

% handle input
assert(nargin>=3,'ERROR: insufficient number of inputs');

if all(size(x)==size(y))
    % do nothing
elseif numel(x)==1
    x=repmat(x,size(y));
elseif numel(y)==1
    y=repmat(y,size(x));
else
    error('ERROR: inconsistent (x,y) input');
end

zGrid=1:object.NumberImages;
z=interp3(object.Grid1,object.Grid2,zGrid,object.Data,x,transpose(y),zGrid,'linear');

end