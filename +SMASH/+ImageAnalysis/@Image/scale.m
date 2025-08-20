% SCALE Multiply an Image object by a scalar value
%
% Usage:
%   >> object=scal(object,coordinate,value)
% The "coordinate" input may be 'Grid1' or 'Grid2'.
%
% See also IMAGE, map, shift

% created October 4, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function object=scale(object,coordinate,value)

% handle input
if nargin<2
    error('ERROR: coordinate must be specified');
end

if nargin<3
    error('ERROR: scale value must be specified');
end

if isempty(value) || (numel(value)~=1)
    error('ERROR: scale value must be a single number');
end

% apply scale
value=[value 0];
object=map(object,coordinate,'polynomial',value);  

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);

end