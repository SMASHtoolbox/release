function [handle,position]=button(varargin)

handle=uicontrol('Style','pushbutton',varargin{:});
position=get(handle,'Position');
extent=get(handle,'Extent');

position(3)=extent(3)*1.50;
position(4)=extent(4)*1.50;
set(handle,'Position',position);

end