% box Draw a box around specified items
%
% This method draws box around items in a dialog box.  The box size is
% determined by the outermost boundaries of the specified items.
%    ha=box(object,target);
% The input "target" is an array of graphic handles: uicontrols, tables,
% and axes objects.
% 
% See also Dialog, addblock
%

%
% created September 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function ha=box(object,target)

% find (x,y) limits
for n=1:numel(target)
    try
    parent=get(target(n),'Parent');
    assert(parent==object.Handle);
    catch
        error('ERROR: invalid target handle(s)');
    end
    type=get(target(n),'Type');
    if strcmpi(type,'axes')
        pos=get(target(n),'OuterPosition');
    else
        pos=get(target(n),'Position');
    end    
    if n==1
       xmin=pos(1);
       xmax=pos(1)+pos(3);
       ymin=pos(2);
       ymax=pos(2)+pos(4);
    else
        xmin=min(xmin,pos(1));
        xmax=max(xmax,pos(1)+pos(3));
        ymin=min(ymin,pos(2));
        ymax=max(ymax,pos(2)+pos(4));
    end    
end

% add margins
xmin=xmin-object.HorizontalMargin/2;
xmax=xmax+object.HorizontalMargin/2;

ymin=ymin-object.VerticalMargin/2;
ymax=ymax+object.VerticalMargin/2;

% create axes
ha=axes('Parent',object.Handle,'Units','pixels',...
    'Position',[xmin ymin xmax-xmin ymax-ymin],...
    'XTick',[],'YTick',[],'Box','on','Color','none');

object.Boxes(end+1)=ha;

end