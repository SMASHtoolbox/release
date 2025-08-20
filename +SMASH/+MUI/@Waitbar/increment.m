% INCREMENT Increment Waitbar object
%
% This method advances Waitbar object by the specified increment.  The
% graphical bar is updated when the accumulated increments exceed the
% threshold.
%
%
% See also Waitbar, reset, update
%

% created October 9, 2013 by Daniel Dolan (Sandia National Laboratories)
function increment(object,value)

if nargin<2
    error('ERROR: no increment specified');
end

if ~isnumeric(value) || numel(value)~=1
    error('ERROR: invalid increment specified');
end   

progress=object.Progress+value;
update(object,progress);

end