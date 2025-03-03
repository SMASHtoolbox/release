% getcurve     Returns (x,y) data for a line displayed in a figure
% [x,y]=getcurve;    gets data from current line
% [x,y]=getcurve(h);     gets data from the line with handle h
% 
% [x,y]=getcurve('xlim'); % extract data with current x limits
% [x,y]=getcurve('ylim);
% [x,y]=getcurve('xylim');

% updated 2/9/2008 by Daniel Dolan

function [x,y]=getcurve(varargin)

% determine object handle
if (nargin>0) && ishandle(varargin{1})
    hline=varargin{1};
    options=varargin(2:end);
else
    hline=gco;
    options=varargin;
end
haxes=get(hline,'Parent');

% interpret options
limit='none';
for k=1:numel(options)
    switch options{k}
        case {'xlim','ylim','xylim','none'}
            limit=options{k};
        otherwise
            error('ERROR: %s is an unrecognized options',options{k});
    end
end

% extract object data
type=get(hline,'Type');
if strcmp(type,'line')
    x=get(hline,'XData');
    y=get(hline,'YData');
else
    error('ERROR: specified object is not a line.');
end

% apply limits
switch limit
    case 'xlim'
        xb=xlim(haxes);
        ind=((x>=xb(1)) & (x<=xb(2)));
        x=x(ind);
        y=y(ind);
    case 'ylim'
        yb=ylim(haxes);
        ind=((y>=yb(1)) & (y<=yb(2)));
        x=x(ind);
        y=y(ind);
    case 'xylim'
        xb=xlim(haxes);
        xind=((x>=xb(1)) & (x<=xb(2)));
        yb=ylim(haxes);
        yind=((y>=yb(1)) & (y<=yb(2)));
        ind=(xind & yind);
        x=x(ind);
        y=y(ind);
    case 'none'
        % do nothing
end
