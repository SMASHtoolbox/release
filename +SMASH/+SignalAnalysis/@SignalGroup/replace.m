% REPLACE Replace data values in an object
%
% This method replaces elements of the Data property in a SignalGroup
% object. Replacement can be specified by a logical array:
%    >> object=replace(object,object.Grid<0,value); % replace Data at negative Grid locations
% or with a [upper lower] bound array.
%    >> object=replace(object,[-inf 0],value); % same result as above
% The replacement value can be a scalar or an array that matches the
% replacement size.
% 
% See also SignalGroup
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
elseif strcmpi(array,'all')
    array=true(size(object.Grid));
elseif isnumeric(array) && (numel(array)==2)
    array=(object.Grid>=array(1)) & (object.Grid<=array(2));
else
    error('ERROR: invalid replacement array');    
end

if isscalar(value)
    % do nothing
elseif (size(value,1)==1) && (size(value,2)==object.NumberSignals)
    value=repmat(value,sum(array),1);
else
    error('ERROR: incompatible array size');
end
object.Data(array,:)=value;

object=updateHistory(object);

end