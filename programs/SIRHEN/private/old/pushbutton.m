function [h,pos]=pushbutton(parent,pos,string,varargin)

if isempty(pos)
    pos=[1 1];
end

[h,posA]=custom_uicontrol('Parent',parent,'Style','pushbutton','string',string);
pos=[pos(1:2) posA(3:4)];
set(h,'Position',pos,varargin{:});