% SCALE Scale object Grid array
%
% This method multiplies a Signal object's Grid array by a scalar value,
% stretching or compressing the horizontal axis.
%    object=scale(object,value);
%
% See also Signal, map, shift
%

%
% created October 4, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=scale(object,value)

% handle input
if nargin<2
    error('ERROR: scale value must be specified');
end

if isempty(value) || (numel(value)~=1)
    error('ERROR: scale value must be a single number');
end

% apply shift
value=[value 0];
object=map(object,'Grid','polynomial',value);  

object.ObjectHistory=object.ObjectHistory(1:end-1); % remove extra 'map'
object=updateHistory(object);

end