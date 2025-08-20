% squeeze Remove white space
%
% This method removes extraneous white space from a dialog box
%    squeeze(object)
%
% See also Dialog
%

%
%
%
function squeeze(object)

h=get(object.Handle,'Children');

% determine control shift
x0=inf;
y0=inf;
for n=1:numel(h)
    switch get(h(n),'Type')
        case 'uimenu'
            continue
    end
    pos=getpixelposition(h(n),true);
    x0=min(x0,pos(1));
    y0=min(y0,pos(2));
end
dx=x0-object.HorizontalMargin;
dy=y0-object.VerticalMargin;

% apply control shift
for n=1:numel(h)
    switch get(h(n),'Type')
        case 'uimenu'
            continue
    end
    pos=getpixelposition(h(n),true);
    pos(1)=pos(1)-dx;
    pos(2)=pos(2)-dy;
    setpixelposition(h(n),pos,true);    
end

% resize figure
Lx=0;
Ly=0;
for n=1:numel(h)
    switch get(h(n),'Type')
        case 'uimenu'
            continue
    end
    pos=getpixelposition(h(n),true);
    Lx=max(Lx,pos(1)+pos(3));
    Ly=max(Ly,pos(2)+pos(4));
end
pos=getpixelposition(object.Handle);
pos(3)=Lx+object.HorizontalMargin;
pos(4)=Ly+object.VerticalMargin;
setpixelposition(object.Handle,pos);

end