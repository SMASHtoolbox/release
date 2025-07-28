function [h,pos]=editbox(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

[h,posA]=custom_uicontrol('Parent',parent,'Style','edit','String',string);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});

set(h,'BackgroundColor',[1 1 1]);