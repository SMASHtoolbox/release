% RESET Rest Waitbar object
%
% This method resets a Waitbar object to zero progress.
%    >> reset(object);
%
% See also Waitbar, increment, update
%

% created October 10, 2013 by Daniel Dolan (Sandia National Laboratories)

function reset(object)

if ~ishandle(object.Handle)
    error('ERROR: wait bar no longer exists');
end
object.Progress=0;
object.Bar=0;
waitbar(0,object.Handle);

end