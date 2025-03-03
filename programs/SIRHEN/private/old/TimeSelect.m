function TimeSelect(varargin)

src=varargin{1};
fig=ancestor(src,'figure');
h=findobj(fig,'Type','uitoolbar');
h=get(h,'Children');

if get(src,'Value')==1
    set(h,'Enable','off');
else
    set(h,'Enable','on');
end
