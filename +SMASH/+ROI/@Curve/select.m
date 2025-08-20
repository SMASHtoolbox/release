% select Interactive curve selection
%
% This method provides interactive selection of curve points using the mouse.
%    object=select(object); % use current axes
%    object=select(object,target); % use target axes
% Simultaneous selection is performed when multiple target objects (within
% the same figure) are specified.
%
% See also Curve, define, view
%
function object=select(object,target)

%% manage input
assert(isscalar(object),...
    'ERROR: interactive selection must be done one region at a time');

if (nargin < 2) || isempty(target)
    target=gca;    
else
    for k=1:numel(target)
        assert(ishandle(target(k)) && strcmpi(target(k).Type,'axes'),...
            'ERROR: invalid target axes');       
    end    
end

%% launch appropriate GUI
switch lower(SMASH.Graphics.checkGraphics())
    case 'java'
        object=selectLegacy(object,target);
    case 'javascript'
        object=selectCurrent(object,target);
end

end
