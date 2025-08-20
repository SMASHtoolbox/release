% overlay Overlay two axes objects
%
% This function overlays two axes objects in a new figure.
%    overlay(haxes);
% The input "haxes" must contain two axes handles.  Labels and tick marks
% for the first axes are shown on the bottom/left, while the second axes
% uses the top/right.
%
% Overlaid axes can be linked with a second input.
%    overlay(haxes,'x'); % horizontal linking 
%    overlay(haxes,'y'); % vertical linking
%    overlay(haxes,'xy'); % linking in both directions
%    overlay(haxes,'off'); % no linking (default)
%
% Axes handles created by this function are returned as outputs, as
% requested.
%    new=overlay(haxes);
%
% <a href="matlab:SMASH.System.showExample('AxesOverlay','+SMASH/+Graphics/+AxesTools')">Examples</a>
%
% See also SMASH.Graphics.AxesTools
%

%   
% created March 5, 2018 by Daniel Dolan
%
function varargout=overlay(haxes,option)

% manage input
assert(nargin > 0,'ERROR: no axes handles specified');

assert(numel(haxes) == 2,'ERROR: two axes handles are needed')
for n=1:2
    assert(ishandle(haxes(n)),'ERROR: invalid axes handle(s)');
end

if (nargin < 2) || isempty(option)
    option='off';
else
    assert(ischar(option),'ERROR: invalid link option');
    option=lower(option);   
    switch option
        case {'x' 'y' 'xy' 'off'}
            % keep going
        otherwise
            error('ERROR: %s is not a valid link option',option);
    end
end

% copy axes to new figure
fig=figure('Visible','off');

ax(1)=copyobj(haxes(1),fig);
ax(2)=copyobj(haxes(2),fig);
set(ax,'Color','none','Box','off');
setappdata(fig,'PositionLink',linkprop(ax,'Position'));
set(ax(1),'OuterPosition',[0 0 1 1]);

set(ax(2),'YAxisLocation','right','XAxisLocation','top');

% link axes as requested
linkaxes(ax,option);
switch option
    case 'x'
        xlabel(ax(2),'');
        set(ax(2),'XTickLabel','');
    case 'y'
        ylabel(ax(2),'');
        set(ax(2),'YTickLabel','');
    case 'xy'
        xlabel(ax(2),'');
        set(ax(2),'XTickLabel','');
        ylabel(ax(2),'');
        set(ax(2),'YTickLabel','');
end

figure(fig);

% manage output
if nargout > 0
    varargout{1}=haxes;
end

end