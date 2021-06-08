% trim Trim excess dialog width
%
% This method trims excess width from a dialog box.
%    trim(object);
% Trimmed dialogs are fit all existing blocks with horizontal margin in
% either side.  
%
% Excess space arises from the automatic sizing of text entries.  Sizing
% assumes a fixed width font, but text is often shown in a proportional
% font.
%
% See also Dialog
%

%
% created December 13, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function trim(object)

h=get(object.Handle,'Children');
figpos=getpixelposition(object.Handle);
x=[figpos(3) 1];
y=[figpos(4) 1];
for n=1:numel(h)
    pos=getpixelposition(h(n));
    x(1)=min(x(1),pos(1));   
    y(1)=min(y(1),pos(2));   
    if isprop(h(n),'Extent')
       extent=get(h(n),'Extent');
       pos(3)=max(pos(3),extent(3));
       pos(4)=max(pos(4),extent(4));
    end
    x(2)=max(x(2),pos(1)+pos(3));
    y(2)=max(y(2),pos(2)+pos(4));    
end

DialogPosition=getpixelposition(object.Handle);
DialogPosition(3)=diff(x);
DialogPosition(4)=diff(y);
setpixelposition(object.Handle,DialogPosition);

for n=1:numel(h)
    pos=getpixelposition(h(n));
    pos(1)=pos(1)-x(1);
    pos(2)=pos(2)-y(1);
    setpixelposition(h(n),pos);
end

end