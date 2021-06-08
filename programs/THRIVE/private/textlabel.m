function [h,pos]=textlabel(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

[h,posA]=custom_uicontrol('Parent',parent,'Style','text','String',string);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});

% match the parent color
switch lower(get(parent,'Type'))
    case 'figure'
        bgcolor=get(parent,'Color');
    otherwise
        bgcolor=get(parent,'BackgroundColor');
end
set(h,'BackgroundColor',bgcolor);