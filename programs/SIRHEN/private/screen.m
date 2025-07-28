function [fig,button,haxes,hp]=screen(varargin)

% probe primary monitor size
monpos=get(0,'MonitorPositions');
diagonal=monpos(:,3).^2+monpos(:,4).^2;
[~,keep]=max(diagonal);
monLx=monpos(keep,3);
monLy=monpos(keep,4);
fig=MinimalFigure('Visible','off','units','pixels',...
    'NumberTitle','off','IntegerHandle','off',varargin{:});
Ly=0.80*monLy;
Lx=min([(8.5/11)*Ly 0.80*monLx]);
%x0=monpos(1)+(monLx-Lx)/2;
%y0=monpos(2)+(monLy-Ly)/2;
set(fig,'Position',[0 0 Lx Ly]);
movegui(fig,'center');

% create control buttons
button(1)=uicontrol('Style','pushbutton','String',' < Previous ',...
    'Tag','previous','Units','pixels');
button(2)=uicontrol('Style','pushbutton','String',' Next > ',...
    'Tag','next','Units','pixels');

width=0;
height=0;
for n=1:numel(button)
    extent=get(button(n),'Extent');
    width=max([width 1.25*extent(3)]);
    height=max([height 1.250*extent(4)]);
end
set(button,'Position',[1 1 width height]);

% create plots
hp=uipanel('Parent',fig,'Tag','plots','Units','pixels',...
    'BackGroundColor',get(fig,'Color'),...
    'BorderType','none');
haxes(1)=axes('Parent',hp,'Box','on',...
    'Units','normalized','OuterPosition',[0 1/2 1 1/2]);
haxes(2)=axes('Parent',hp,'Box','on',...
    'Units','normalized','OuterPosition',[0 0/2 1 1/2]);
%linkaxes(ha,'x');


% final stuff
set(fig,'ResizeFcn',@ResizeFcn);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure resize function %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function ResizeFcn(fig,varargin)

% get size information
figpos=get(fig,'Position');
h=guihandles(fig);
haxes=findobj(fig,'Type','axes');

pos_prev=get(h.previous,'Position');
pos_next=get(h.next,'Position');

% enforce minimum size
Lxmin=2*(pos_prev(3)+pos_next(3));
if figpos(3)<Lxmin
    figpos(3)=Lxmin;
end

%Lymin=10*pos_prev(4);
Lymin=9*Lxmin/16;
if figpos(4)<Lymin
    dy=Lymin-figpos(4);
    figpos(2)=figpos(2)-dy;
    figpos(4)=Lymin;
end
set(fig,'Position',figpos);

% position buttons and panel
margin=pos_prev(4)/2;

x0=margin;
y0=margin;
pos=[x0 y0 pos_prev(3:4)];
set(h.previous,'Position',pos)

x0=figpos(3)-margin-pos_next(3);
pos=[x0 y0 pos_next(3:4)];
set(h.next,'Position',pos)

%y0=0;
y0=margin+pos_next(4);
Ly=figpos(4)-y0;
pos=[0 y0 figpos(3) Ly];
set(h.plots,'Position',pos);