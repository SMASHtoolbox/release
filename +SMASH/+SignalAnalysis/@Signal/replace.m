% REPLACE Replace Data values
%
% This method replaces Data values in a Signal object. Replacement can be
% specified by a logical array:
%    >> object=replace(object,object.Grid<0,value); % negative Grid locations
% or with a [upper lower] bound array.
%    >> object=replace(object,[left right],value); % left/right Grid bounds
% The replacement value can be a scalar or an array that matches the
% replacement size.
% 
% See also Signal, reset
%

%
% created November 19, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=replace(object,array,value)

% handle input
assert(nargin==3,'ERROR: invalid number of inputs');

% interpret array input
if islogical(array) && (numel(array)==numel(object.Grid))    
    % valid request 
elseif strcmpi(array,'all') || isempty(array)
    array=true(size(object.Grid));
elseif isnumeric(array) && (numel(array)==2)
    array=(object.Grid>=array(1)) & (object.Grid<=array(2));
else
    error('ERROR: invalid replacement array');    
end
object.Data(array)=value;

object=updateHistory(object);

end