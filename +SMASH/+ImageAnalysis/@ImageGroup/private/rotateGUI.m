function object = rotateGUI(object,varargin)
%%
% This GUI is a wrapper around SMASH.ImageAnalysis.Image.Rotate that allows
% the user to perform 90 degree rotations and arbitrary angle rotations.
% When the "done" button is pressed the rotations are saved to the output
% object.
%
% created May 27, 2014 by Patrick Knapp (Sandia National Laboratories)
% revised February 7, 2016 by Daniel Dolan
%    -updated dialog box for consistency with new handle graphics system
%    -changed dialog box layout
% revised March 23, 2016 by Sean Grant (SNL / UT)
%    -changed for ImageGroup
%%
h=findall(0,'Type','figure','Tag','guiRotate');
if ishandle(h)
    figure(h);
    return
end

angleLast=0; % Provide a check for whether an angle rotation was performed last.
new=object; % Placeholder so 'new' is a wider variable.

%% Create MUI figure and show object
figRadiography=SMASH.MUI.Figure('NumberTitle','off');
figRadiography.Name='Rotated image';
setappdata(figRadiography.Handle, 'obj_Rotate', []);

%imagesc(object.Grid1,object.Grid2,object.Data);
ax1 = gca;
hView=view(object,'show',ax1);
hold on
GridPlot();

%% Create Dialog box to manipulate image
diaRotate=SMASH.MUI.Dialog;
diaRotate.Hidden=true;
diaRotate.Name='Interactive rotation';
set(diaRotate.Handle,'Tag','guiRotate');

%h=addblock(diaRotate,'text','Image rotation');
%set(h,'FontWeight','bold');
hARB=addblock(diaRotate,'edit_button',{'Angle (degrees):',' Apply '}); % Edit box to input rotation angle
%set(hARB(1),'FontWeight','bold');
set(hARB(3),'Callback',@RotCallback);
%hRot=addblock(diaRotate,'button',' Update '); % update figure
%set(hRot,'Callback',@RotCallback); % rotates image by value in edit box and updates the figure
%addblock(diaRotate,'text','90 degree rotation');
%hR=addblock(diaRotate,'button',{'Right' 'Left'});

addblock(diaRotate,'text',' ');
h=addblock(diaRotate,'text','90 degree rotations:');
%set(h,'FontWeight','bold');
hR=addblock(diaRotate,'button',{'Right' 'Left'});
set(hR(1),'Callback',@CWcallback,...
    'TooltipString','90 degrees clockwise'); % button rotates image clockwise
set(hR(2),'Callback',@CCWcallback,...
    'TooltipString','90 degrees counter-clockwise'); % button rotates image counter-clockwise

addblock(diaRotate,'text',' ');
h=addblock(diaRotate,'text','180 degree flips:');
%set(h,'FontWeight','bold');
hF=addblock(diaRotate,'button',{'Vertical' 'Horizontal'}); % clockwise rotation button block
set(hF(1),'Callback',@UDcallback); % button rotates image clockwise
%hFlr=addblock(diaRotate,'button',' Flip L/R '); % clockwise rotation button block
set(hF(2),'Callback',@LRcallback); % button rotates image clockwise

hRot=addblock(diaRotate,'button',' Done '); % commits the rotation and grabs the new object
set(hRot,'Callback',@DoneCallback);

% Move dialog box so it doesn't overlap the figure window
Pos_dia = get(diaRotate.Handle,'Position');
Move_dia = [Pos_dia(3) 0 0 0];
set(diaRotate.Handle,'Position',Pos_dia-Move_dia,...
    'CloseRequestFcn',@DoneCallback)

diaRotate.Hidden=false;
uiwait;

object = getappdata(figRadiography.Handle, 'obj_Rotate');
delete(figRadiography.Handle);

    function CWcallback(varargin)
        object = rotate(object,'right');
        set(hView.image,'XData',object.Grid1,'YData',object.Grid2,...
            'CData',object.Data(:,:,1));
        GridPlot()
        angleLast=0;
    end

    function CCWcallback(varargin)
        object = rotate(object,'left');
        set(hView.image,'XData',object.Grid1,'YData',object.Grid2,...
            'CData',object.Data(:,:,1));
        GridPlot()
        angleLast=0;
    end

    function UDcallback(varargin)
        object = flip(object,'Grid2');
        set(hView.image,'XData',object.Grid1,'YData',object.Grid2,...
            'CData',object.Data(:,:,1));
        GridPlot()
        angleLast=0;
    end

    function LRcallback(varargin)
        object = flip(object,'Grid1');
        set(hView.image,'XData',object.Grid1,'YData',object.Grid2,...
            'CData',object.Data(:,:,1));
        GridPlot()
        angleLast=0;
    end

    function RotCallback(varargin)
        value=probe(diaRotate);
        angle=sscanf(value{1},'%g');
        new = rotate(object,angle);
        set(hView.image,'XData',new.Grid1,'YData',new.Grid2,...
            'CData',new.Data(:,:,1));
        GridPlot()
        angleLast=1;
    end

    function DoneCallback(varargin)
        delete(diaRotate);
%         hData = findobj(gca,'Type','Image');
%         RData = get(hData,'CData');
%         xData = get(hData,'XData');
%         yData = get(hData,'YData');
%         obj_Rot = SMASH.ImageAnalysis.Image(xData,yData,RData);
        if angleLast
            obj_Rot=new;
        else
            obj_Rot=object;
        end
        setappdata(figRadiography.Handle, 'obj_Rotate', obj_Rot);
    end

    function GridPlot(varargin)
        h=findobj(ax1,'Tag','GridPlot');
        delete(h);
        xlims = get(ax1,'XLim');
        Dx = xlims(2)-xlims(1);
        ylims = get(ax1,'YLim');
        Dy = ylims(2)-ylims(1);
        
        NumLines = 5;
        xLocs = linspace(xlims(1)+0.1*Dx,xlims(2)-0.1*Dx,NumLines);
        yLocs = linspace(ylims(1)+0.1*Dy,ylims(2)-0.1*Dy,NumLines);
        
        for i = 1:NumLines
            plot(ax1,[xLocs(i) xLocs(i)],ylims,'Color','m','Tag','GridPlot')
            plot(ax1,xlims,[yLocs(i) yLocs(i)],'Color','m','Tag','GridPlot')
        end
        
    end

end