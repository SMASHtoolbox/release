function object=create(object,varargin)

%%
%%
if nargin > 1
    option=varargin;
else
    option={};
end

temp=SMASH.MUI.Figure('NumberTitle','off','Name',object.PrivateName);
object.Figure=temp.Handle;
try
    set(object.Figure,'SizeChangedFcn',@resizeFigure);
catch
    set(object.Figure,'ResizeFcn',@resizeFigure);
end
    function resizeFigure(varargin)
        set(object.Figure,'Units','pixels');
        set(object.ControlPanel,'Units','pixels');
        set(object.PlotPanel,'Units','pixels');
        %
        FigPosition=get(object.Figure,'Position');
        ControlPosition=get(object.ControlPanel,'Position');
        minwidth=2*ControlPosition(3);
        if FigPosition(3) < minwidth
            FigPosition(3) = minwidth;
        end
        minheight=ControlPosition(4);
        if FigPosition(4) < minheight
            change=minheight-FigPosition(4);
            y0=FigPosition(2);
            FigPosition(2) = y0-change;
            FigPosition(4) = minheight;
        end
        FigPosition(3:4)=ceil(FigPosition(3:4));
        set(object.Figure,'Position',FigPosition);
        %
        ControlPosition(1)=0;
        ControlPosition(2)=FigPosition(4)-ControlPosition(4);
        set(object.ControlPanel,'Position',ControlPosition);        
        %
        PlotPosition=FigPosition;
        PlotPosition(1)=ControlPosition(3);
        PlotPosition(3)=PlotPosition(3)-PlotPosition(1);
        PlotPosition(2)=0;
        set(object.PlotPanel,'Position',PlotPosition);        
    end

%%
object.ControlPanel=uipanel(...
    'Units','normalized','Position',[0 0 0.20 1],...
    'BorderType','none','HandleVisibility','callback');

object.PlotPanel=uipanel(...
    'Units','normalized','Position',[0.20 0 0.80 1],...
    'BorderType','none');
axes('Parent',object.PlotPanel,'Box','on');

%%
object.DialogBox=SMASH.MUI.Dialog(option{:});
object.DialogBox.Hidden=true;

setappdata(object.Figure,'DialogPlot',object);

end