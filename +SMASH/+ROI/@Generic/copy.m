% copy Copy existing region of interest
%
% This method copies an existing region of interest and appends this copy
% to the end of the object array.
%    object=copy(object); % copy last ROI
%    object=copy(object,index); % copy specific ROI
% The number of array elements increases by one each time this method is
% called.
%

%
% created October 2, 2017 by Daniel Dolan (Sandia National Laboratory)
%
function object=copy(object,index)

% manage input
assert(numel(object) >= 1,'ERROR: empty objects cannot be copied');

if (nargin < 2) || isempty(index)
    index=numel(object);
end
valid=1:numel(object);
assert(isscalar(index) && isnumeric(index) && (any(index == valid)),...
    'ERROR: invalid index');

% perform copy operation
object(end+1)=object(index);

end