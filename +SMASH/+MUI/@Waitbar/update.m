% UPDATE Update Waitbar object
%
% This method updates a Waitbar object *if* the requested state differs
% from the current state by more than the threshold amount.
%
% Example:
%    >> w=Waitbar('Calculation progress','progress'); % Progress starts at 0
%    w.Threshold=0.25; % set threshold at 25%
%    update(w,0.10); % nothing happens
%    update(w,0.30); % progress bar moves to 30%
%    update(w,0.50); % nothing happens
%    update(w,0.55); % progress bar moves to 55%
%
% See also Waitbar, reset
%

% created October 9, 2013 by Daniel Dolan (Sandia National Laboratories)
function update(object,value)

if nargin<2
    error('ERROR: no update value specified');
end

if ~isnumeric(value) || numel(value)~=1
    error('ERROR: invalid progress specified');
elseif value>=1
    object.Progress=1;
    object.Bar=1;
    object.Done=true;
    if object.AutoClose && ishandle(object.Handle)
        delete(object.Handle);
    end
elseif ~ishandle(object.Handle)
    error('ERROR: wait bar no longer exists');
end

object.Progress=value;
change=object.Progress-object.Bar;
if change>=object.Threshold
    waitbar(value,object.Handle);
    object.Bar=value;
end

end