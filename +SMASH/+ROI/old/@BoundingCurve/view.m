% view Display a BoundingCurve
%
% This method displays the points and envelope of a BoundingCurve object.
%     >> view(object); % display in new figure
%     >> view(object,target); % display in target axes
% The graphic handles created by the method are returned as outputs.
%     >> [points,envelope]=view(...);
%
% See also BoundingCurve, select
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised December 5, 2014 by Daniel Dolan
%   -Converted output to hggroup for GUI development
function varargout=view(object,target)

% manage input
if (nargin<2) || isempty(target)
    figure;
    target=axes('Box','on');
end
assert(ishandle(target),'ERROR: invalid target axes handle');

if isempty(object.Data)
    x=[];
    y=[];
    width=[];
else
    x=object.Data(:,1);
    y=object.Data(:,2);
    width=object.Data(:,3);
end

% plot points
parent=hggroup('Parent',target);

points=line('Parent',parent,'XData',x,'YData',y,...
    'Tag','SMASH.ROI.BoundingCurve');
apply(object.GraphicOptions,points,'noparent');
setappdata(parent,'Points',points);

% plot envelope
switch object.Direction
    case 'horizontal'
        x=[x; x(end:-1:1)];
        y=[y+width; y(end:-1:1)-width(end:-1:1)];
    case 'vertical'
        x=[x+width; x(end:-1:1)-width(end:-1:1)];
        y=[y; y(end:-1:1)];
end
if ~isempty(x)
    x(end+1)=x(1);
    y(end+1)=y(1);
end
%envelope=line('Parent',parent,'XData',x,'YData',y);
envelope=SMASH.Graphics.AlternatingLine('Parent',parent,...
    'XData',x,'YData',y,...
    'LineWidth',object.GraphicOptions.LineWidth,...
    'ForegroundColor',object.GraphicOptions.LineColor);
complement(envelope);
setappdata(parent,'Envelope',envelope);

bg=get(envelope.Group,'Children');
apply(object.GraphicOptions,bg,'noparent');
set(bg,'Marker','none');
complement(envelope);

% handle output
if nargout>0
    varargout{1}=parent;
end

end