% view Display bounding lines
%
% This method displays bounding lines in a MATLAB axes.
%     >> view(object,target);
% If the target axes handle is omitted, lines are drawn in the current
% axes.  Line handles are returned as the output of this method.
%     >> hline=view(...);
%
% See also BoundingLines, select
%

%
% created November 14, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,target)

% handle input
if (nargin<2) || isempty(target)
    figure;
    target=axes('Box','on');
end
assert(ishandle(target),'ERROR: invalid target axes handle');
assert(strcmpi(get(target,'Type'),'axes'),...
    'ERROR: invalid target axes handle');

% generate plots
assert(~isempty(object.Data),'ERROR: no data found');

switch object.Direction
    case 'horizontal'
        xb1=xlim(target);
        yb1=repmat(object.Data(1),[1 2]);
        xb2=xb1;
        yb2=repmat(object.Data(2),[1 2]);
    case 'vertical';
        xb1=repmat(object.Data(1),[1 2]);
        yb1=ylim(target);
        xb2=repmat(object.Data(2),[1 2]);
        yb2=yb1;
end
envelope(1)=line('Parent',target,'XData',xb1,'YData',yb1);
envelope(2)=line('Parent',target,'XData',xb2,'YData',yb2);
apply(object.PlotOptions,envelope);
set(envelope,'Marker','none','Tag','SMASH.ROI.BoundingLine');

% handle output
if nargout>0
    varargout{1}=envelope;
end

end