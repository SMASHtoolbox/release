% FINALIZE Complete Dialog object
%
%    >> finalize(object);

%
function finalize(object)

figpos=get(object.Handle,'Position');
width=0;
h=findall(object.Handle,'Type','uicontrol');
for n=1:numel(h)
    pos=get(h(n),'Position');
    extent=get(h(n),'Extent');
    width=max([width pos(1)+extent(3)+object.HorizontalMargin]);
end
figpos(3)=width;

set(object.Handle,'Position',figpos);

end