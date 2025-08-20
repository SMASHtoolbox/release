% SHIFT Shifts a Image object by a scalar value
%
% Usage:
%   >> object=shift(object,coordinate,value)
% The "coordinate" input may be 'Grid1' or 'Grid2'.
%
% See also IMAGE, map, scale

% created October 4, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified October 16, 2013 by Tommy Ao (Sandia National Laboratories)
%
function object=shift(object,coordinate,value)

% handle input
if nargin<2
    error('ERROR: coordinate must be specified');
end

if nargin<3
    error('ERROR: shift value must be specified');
end

if isempty(value) || (numel(value)~=1)
    error('ERROR: shift value must be a single number');
end

% apply shift
value=[1 value];
object=map(object,coordinate,'polynomial',value); 

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);

end