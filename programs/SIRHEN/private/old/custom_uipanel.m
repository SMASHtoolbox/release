function h=custom_uipanel(varargin)

h=uipanel(varargin{:});
parent=get(h,'Parent');
set(h,'Units','pixels',...
    'BackGroundColor',get(parent,'Color'),'BorderType','none');