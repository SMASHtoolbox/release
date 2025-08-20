% LOOKUP Look up data values at specific grid locations
%
% This method returns interpolated data values for specified grid
% locations.
%    >> z=lookup(object,x,y);
%
% See also Image, regrid
% 

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
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

z=interp2(object.Grid1,object.Grid2,object.Data,x,y,'linear');

end