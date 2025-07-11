% LOOKUP Look up data values at specific grid locations
%
% This method returns interpolated data values for specified grid
% locations.
%    >> y=lookup(object,x);
%
% See also Signal, regrid
% 

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function y=lookup(object,x,extrap)

% handle input
if (nargin<2) || isempty(x)
    error('ERROR: no grid location(s) specified');
end

if  (nargin<3) || isempty(extrap)
    extrap=NaN;
end

% perform interpolation

y=interp1(object.Grid,object.Data,x,'linear',extrap);

end