% basic_figure: create a basic figure for imaging visualization
%

% created October 8, 2012 by Daniel Dolan (Sandia National Laboratories)
% revised May 29, 2013 by Daniel Dolan
%    -added support for existing figures
function h=basic_figure(target,orientation)

% handle input
if (nargin<1) 
    target=[];
end

if (nargin<2)
    orientation='';
end

mainpos=get(0,'ScreenSize');
Lx=mainpos(3);
Ly=mainpos(4);

switch orientation
    case 'portrait'
        figpos=[0 0 Lx/2 Ly];
    case 'landscape'
        figpos=[0 0 Lx   Ly/2];
    case 'full'
        figpos=[0 0 Lx   Ly];
    otherwise
        figpos=[0 0 Lx/2 Ly/2];
end

% create graphic objects
if isempty(target)
    object=SMASH.MUI.Figure;
    h.figure=object.Handle;
    set(h.figure,'NumberTitle','on','Name','Image view');
    %h.figure=figure;
else
    h.figure=target;
    clf(target);
end
set(h.figure,'Units','pixels','Position',figpos,...
    'Visible','off');
%set(h.figure,'DockControls','off',...
%    'ToolBar','figure','MenuBar','none',...
%    'Units','pixels','Position',figpos,...
%    'Visible','off');
movegui(h.figure,'northeast');
color=get(h.figure,'Color');

h.panel=uipanel('Parent',h.figure,'Tag','GraphicPanel',...
    'BorderType','none','BackgroundColor',color,...
    'Units','normalized','Position',[0 0 1 1]);  

% tweak the figure menu
%hb=findall(h.figure,'Type','uitoolbar');
%hb=findall(hb);
%hb=hb(2:end);
%drop=true(size(hb));
%for n=1:numel(hb)
%    tag=lower(get(hb(n),'Tag'));
%    if strfind(tag,'zoom')
%        drop(n)=false;
%    elseif strfind(tag,'pan')
%        drop(n)=false;
%    elseif strfind(tag,'cursor')
%        drop(n)=false;
%    elseif strfind(tag,'save')
%        drop(n)=false;
%    end
%end
%set(hb(drop),'Visible','off');
%set(hb,'Separator','off');

end