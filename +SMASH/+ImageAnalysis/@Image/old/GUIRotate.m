function object = GUIRotate(object,varargin)
%%
% This GUI is a wrapper around SMASH.ImageAnalysis.Image.Rotate that allows
% the user to perform 90 degree rotations and arbitrary angle rotations.
% When the "done" button is pressed the rotations are saved to the output
% object.
%
% created May 27, 2014 by Patrick Knapp (Sandia National Laboratories)
% modified February 3, 2016 by Tommy Ao (Sandia National Laboratories)
% 
%%
h=findall(0,'Type','figure','Tag','guiRotate');
if ishandle(h)
    figure(h);
    return
end

%% Create MUI figure and show object
figRotate=SMASH.MUI.Figure();
figRotate.Name='Use Dialog Box to Rotate Image';
setappdata(figRotate, 'obj_Rotate', []);

imagesc(object.Grid1,object.Grid2,object.Data);
hold on
ax1 = gca;
GridPlot();

%% Create Dialog box to manipulate image
diaRotate=SMASH.MUI.Dialog;
diaRotate.Hidden=true;
diaRotate.Name='Choose Rotation Angle';
set(diaRotate.Handle,'Tag','guiRotate');

hRcw=addblock(diaRotate,'button',' CW '); % clockwise rotation button block
set(hRcw,'Callback',@CWcallback); % button rotates image clockwise

hRccw=addblock(diaRotate,'button',' CCW '); % counter-clockwise rotation button block
set(hRccw,'Callback',@CCWcallback); % button rotates image counter-clockwise

hFud=addblock(diaRotate,'button',' Flip U/D '); % clockwise rotation button block
set(hFud,'Callback',@UDcallback); % button rotates image clockwise

hFlr=addblock(diaRotate,'button',' Flip L/R '); % clockwise rotation button block
set(hFlr,'Callback',@LRcallback); % button rotates image clockwise

hARB=addblock(diaRotate,'edit',' Rotation Angle [-90,90] ',20); % Edit box to input rotation angle

hRot=addblock(diaRotate,'button',' Update '); % update figure
set(hRot,'Callback',@RotCallback); % rotates image by value in edit box and updates the figure

hRot=addblock(diaRotate,'button',' Done '); % commits the rotation and grabs the new object
set(hRot,'Callback',@DoneCallback);

% Move dialog box so it doesn't overlap the figure window
Pos_dia = get(diaRotate.Handle,'Position');
Move_dia = [Pos_dia(3) 0 0 0];
set(diaRotate.Handle,'Position',Pos_dia-Move_dia)

diaRotate.Hidden=false;
uiwait;

object = getappdata(figRotate, 'obj_Rotate');
delete(figRotate);

    function CWcallback(varargin)
        object = rotate(object,'right');
        axes(ax1)
        hold off
        cla(ax1)
        imagesc(object.Grid1,object.Grid2,object.Data,'Parent',ax1);
        hold on
        GridPlot()
    end

    function CCWcallback(varargin)
        object = rotate(object,'left');
        axes(ax1)
        hold off
        cla(ax1)
        imagesc(object.Grid1,object.Grid2,object.Data,'Parent',ax1);
        hold on
        GridPlot()
    end

    function UDcallback(varargin)
        object = flip(object,'Grid2');
        axes(ax1)
        hold off
        cla(ax1)
        imagesc(object.Grid1,object.Grid2,object.Data,'Parent',ax1);
        hold on
        GridPlot()
    end

    function LRcallback(varargin)
        object = flip(object,'Grid1');
        axes(ax1)
        hold off
        cla(ax1)
        imagesc(object.Grid1,object.Grid2,object.Data,'Parent',ax1);
        hold on
        GridPlot()
    end

    function RotCallback(varargin)
        value=probe(diaRotate);
        angle=sscanf(value{1},'%g');
        object_new = rotate(object,angle);
        axes(ax1)
        hold off
        cla(ax1)
        imagesc(object_new.Grid1,object_new.Grid2,object_new.Data,'Parent',ax1);
        hold on
        GridPlot()
    end

    function DoneCallback(varargin)
        delete(diaRotate);
        hData = findobj(gca,'Type','Image');
        RData = get(hData,'CData');
        xData = get(hData,'XData');
        yData = get(hData,'YData');
        obj_Rot = SMASH.ImageAnalysis.Image(xData,yData,RData);
        setappdata(figRotate, 'obj_Rotate', obj_Rot);
    end

    function GridPlot(varargin)
        xlims = get(ax1,'XLim');
        Dx = xlims(2)-xlims(1);
        ylims = get(ax1,'YLim');
        Dy = ylims(2)-ylims(1);
        
        NumLines = 10;
        xLocs = linspace(xlims(1)+0.1*Dx,xlims(2)-0.1*Dx,NumLines);
        yLocs = linspace(ylims(1)+0.1*Dy,ylims(2)-0.1*Dy,NumLines);
        
        for i = 1:NumLines
            plot(ax1,[xLocs(i) xLocs(i)],ylims,'Color','m')
            plot(ax1,xlims,[yLocs(i) yLocs(i)],'Color','m')
        end
        
    end

end