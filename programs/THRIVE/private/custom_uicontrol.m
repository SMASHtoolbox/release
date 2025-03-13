% customized uicontrol function
function [h,pos]=custom_uicontrol(varargin)

h=uicontrol(varargin{:});
style=get(h,'Style');

% set font
persistent fontname
if isempty(fontname)
    fonts=listfonts;
    fontname='';
    for ii=1:numel(fonts)
        if strcmpi(fonts{ii},'helvetica')
            fontname=fonts{ii};
            break
        end
    end
    if isempty(fontname)
        fontname='fixedwidth';
    end
    %fontname='fixedwidth';
end
%set(h,'FontName',fontname,'FontUnits','points','FontSize',12);
set(h,'FontName',fontname,'FontUnits','points','FontSize',10);

% set units
set(h,'Units','pixels');

% size object based on its contents
pos=get(h,'Position');
extent=get(h,'Extent');
pos(3)=extent(3);
Lymin=1.5*extent(4);
switch style
    case 'popupmenu'
        % do nothing
    otherwise
        pos(4)=Lymin;
end
set(h,'Position',pos);