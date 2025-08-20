function resize(object,fig,varargin)

% determine new position
old=get(fig,'Units');
set(fig,'Units','pixels');
position=get(fig,'Position');

if position(3) < object.BPwidth
    position(3)=object.BPwidth;
end

Lmin=3*object.BPheight;
if position(4) < Lmin
    correction=Lmin-position(4);
    position(4)=Lmin;
    position(2)=position(2)-correction;
end

% correct position and restore units
set(fig,'Position',position,'Units',old);

% deal with button panel
if object.BPheight>0
    % probe button panel
    set(object.ButtonPanel,'Units','pixels');
    position=get(object.ButtonPanel,'Position');
    position(4)=object.BPheight;    
    set(object.ButtonPanel,'Position',position,'Units','normalized');    
    position=get(object.ButtonPanel,'Position');
    % deal with axes panel
    position(2)=position(4);
    position(4)=1-position(2);    
    set(object.AxesPanel,'Position',position);
else
    set(object.AxesPanel,'Position',[0 0 1 1]);
end


end