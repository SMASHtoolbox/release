% select Interactive rectangle selection
%
% This method provides interactive rectangle selection using the mouse.
%    object=select(object); % use the current axes
%    object=select(object,target); % use target axes 
%
% See also Rectangle, define, view
%
function object=select(object,target)

%% manage input
assert(isscalar(object),...
    'ERROR: interactive selection must be done one region at a time');

if (nargin < 2) || isempty(target)
    target=gca;
elseif all(ishandle(target))
     for k=1:numel(target)
        assert(ishandle(target(k)) && strcmpi(target(k).Type,'axes'),...
            'ERROR: invalid target axes');       
    end           
else
    error('ERROR: invalid target axes');
end

%% launch appropriate GUI
switch lower(SMASH.Graphics.checkGraphics())
    case 'java'
        object=selectLegacy(object,target);
    case 'javascript'
    object=selectCurrent(object,target);
end
   
end