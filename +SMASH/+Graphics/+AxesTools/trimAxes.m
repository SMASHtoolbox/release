% trimAxes Trim graphic objects to current axes limits
%
% This function trims lines and images within an axes to the current (x,y)
% limits.
%    trimAxes(); % trim current axes
%    trimAxes(target); % trim axes specitied by "target"
%
% See also SMASH.Graphics
%

%
% created May 29, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function trimAxes(target)

% manage input
if (nargin < 1) || isempty(target)
    target=gca;
end
assert(ishandle(target) && strcmp(get(target,'Type'),'axes'),...
    'ERROR: invalid target axes')

% determine current bounds
xb=get(target,'XLim');
yb=get(target,'YLim');

child=get(target,'Children');
for n=1:numel(child)
    switch get(child(n),'Type')
        case 'line'
            x=get(child(n),'XData');
            y=get(child(n),'YData');
            keep=(x >= xb(1)) & (x <= xb(2)) & (y >= yb(1)) & (y <= yb(2));
            set(child(n),'XData',x(keep),'YData',y(keep));
        case 'image'
            x=get(child(n),'XData');
            y=get(child(n),'YData');
            z=get(child(n),'CData');
            xkeep=(x >= xb(1)) & (x <= xb(2));
            ykeep=(y >= yb(1)) & (y <= yb(2));
            set(child(n),'XData',x(xkeep),'YData',y(ykeep),...
                'CData',z(ykeep,xkeep));
        case 'patch'
            x=get(child(n),'XData');
            y=get(child(n),'YData');
            z=get(child(n),'ZData');
            c=get(child(n),'CData');
            v=get(child(n),'Vertices');
            xkeep=(x >= xb(1)) & (x <= xb(2));
            ykeep=(y >= yb(1)) & (y <= yb(2));
            keep=(xkeep & ykeep);
            set(child(n),'XData',x(keep),'YData',y(keep),...
                'XData',z,'CData',c(keep),'Vertices',v(keep,:));
    end
end

end