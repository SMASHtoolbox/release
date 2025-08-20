% SHIFT Shift object Grid array
%
% This method adds a Signal object's Grid array with a scalar value,
% shifting the horizontal axis.
%    object=shift(object,value);
% 
%
% See also Signal, map, scale
%

%
% created October 4, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=shift(object,value)

% handle input
if nargin<2
    error('ERROR: shift value must be specified');
end

if (numel(value)~=1) || isempty(value)
    error('ERROR: shift value must be a single number');
end

% apply shift
value=[1 value];
object=map(object,'Grid','polynomial',value);

object.ObjectHistory=object.ObjectHistory(1:end-1); % remove extra 'map'
object=updateHistory(object);

end