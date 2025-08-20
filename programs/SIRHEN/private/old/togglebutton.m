function [h,pos]=togglebutton(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

[h,posA]=custom_uicontrol('Parent',parent,'Style','togglebutton','String',string);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});