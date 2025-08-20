function [h,pos]=radiobutton(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

extra=repmat('M',[1 3]);
[h,posA]=custom_uicontrol('Parent',parent,'Style','radio',...
    'string',[string extra]);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});
set(h,'String',string);

% match the parent color
switch lower(get(parent,'Type'))
    case 'figure'
        bgcolor=get(parent,'Color');
    otherwise
        bgcolor=get(parent,'BackgroundColor');
end
set(h,'BackgroundColor',bgcolor);