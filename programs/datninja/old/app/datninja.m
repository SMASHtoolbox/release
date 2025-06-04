
classdef datninja < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                 matlab.ui.Figure
        SessionMenu              matlab.ui.container.Menu
        StartOver                matlab.ui.container.Menu
        LoadPrevious             matlab.ui.container.Menu
        SaveCurrent              matlab.ui.container.Menu
        ExportData               matlab.ui.container.Menu
        ImageMenu                matlab.ui.container.Menu
        LoadGraphicMenu          matlab.ui.container.Menu
        RotateMenu               matlab.ui.container.Menu
        LeftMenu                 matlab.ui.container.Menu
        RightMenu                matlab.ui.container.Menu
        FlipMenu                 matlab.ui.container.Menu
        VerticalMenu             matlab.ui.container.Menu
        HorizontalMenu           matlab.ui.container.Menu
        LogScalingMenu           matlab.ui.container.Menu
        LogNone                  matlab.ui.container.Menu
        LogHorizontal            matlab.ui.container.Menu
        LogVertical              matlab.ui.container.Menu
        LogBoth                  matlab.ui.container.Menu
        MarkerMenu               matlab.ui.container.Menu
        SizeMenu                 matlab.ui.container.Menu
        Marker5                  matlab.ui.container.Menu
        Marker10                 matlab.ui.container.Menu
        Marker15                 matlab.ui.container.Menu
        Marker20                 matlab.ui.container.Menu
        Marker25                 matlab.ui.container.Menu
        Marker50                 matlab.ui.container.Menu
        Marker100                matlab.ui.container.Menu
        ColorMenu                matlab.ui.container.Menu
        ReferenceColor           matlab.ui.container.Menu
        DataColor                matlab.ui.container.Menu
        CurrentPanel             matlab.ui.container.Panel
        yLabel                   matlab.ui.control.Label
        yEdit                    matlab.ui.control.EditField
        mLabel                   matlab.ui.control.Label
        mEdit                    matlab.ui.control.EditField
        nLabel                   matlab.ui.control.Label
        nEdit                    matlab.ui.control.EditField
        xLabel                   matlab.ui.control.Label
        xEdit                    matlab.ui.control.EditField
        StorePoint               matlab.ui.control.Button
        StoredPanel              matlab.ui.container.Panel
        StoredList               matlab.ui.control.ListBox
        MovePoint                matlab.ui.control.Button
        RemovePoint              matlab.ui.control.Button
        PromotePoint             matlab.ui.control.Button
        DemotePoint              matlab.ui.control.Button
        SelectionModePanel       matlab.ui.container.ButtonGroup
        ReferenceButton          matlab.ui.control.RadioButton
        DataButton               matlab.ui.control.RadioButton
        Axes                     matlab.ui.control.UIAxes
        UsekeyboardarrowtoLabel  matlab.ui.control.Label
    end

    
    properties (Access = private)
        Image % Plot image
        CurrentGraphic % Current graphic handle
        ReferenceGraphic % Reference graphic handle
        DataGraphic % Data graphic handle
        Margin=13 % Graphic margin (pixels)
        MinSize % Minimum figure size (pixels)
        PixelFormat='%.2f' % Description
        XDataFormat='%#+.3g' % Description
        YDataFormat='%#+.3g' % Description        
        SessionObject % Description
    end
    
    methods (Access=private)
        function chooseMarkerSize(app,value)
            set([app.CurrentGraphic app.ReferenceGraphic app.DataGraphic],...
                'MarkerSize',value);
            hc=app.SizeMenu.Children;
            set(hc,'Checked','off');
        end
        function state=PointReady(app)
            persistent empty
            if isempty(empty)
                empty=false(1,4);
            end
            empty(1)=isempty(app.mEdit.Value);
            empty(2)=isempty(app.nEdit.Value);
            empty(3)=isempty(app.xEdit.Value);
            empty(4)=isempty(app.yEdit.Value);
            if any(empty)
                state=false;
            else
                state=true;
            end
        end
        function updatePoints(app,data)
            app.StoredList.UserData=data;
            if app.ReferenceButton.Value
                app.SessionObject.ReferenceTable=data;
                set(app.ReferenceGraphic,'XData',data(:,1),'YData',data(:,2));
                try
                    analyzeReference(app.SessionObject)
                    app.DataButton.Enable='on';
                catch
                    app.DataButton.Enable='off';
                end
            elseif app.DataButton.Value
                app.SessionObject.DataTable=data;
                try
                    analyzeData(app.SessionObject);
                catch
                end
                set(app.DataGraphic,'XData',data(:,1),'YData',data(:,2));
            end
        end
        function updateImage(app)
            app.Image.CData=app.SessionObject.Image;
            if isempty(app.SessionObject.ColorMap)
                colormap(app.Axes,gray());
            else
                colormap(app.Axes,app.SessionObject.ColorMap);
            end
            axis(app.Axes,'auto');
            figure(app.UIFigure);
        end
    end
    

    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.UIFigure.Visible='off';
            app.Axes.YDir='reverse';
            app.Axes.Color=app.Axes.Parent.Color;
            app.Image=image(app.Axes,'CData',[],'Tag','SourceImage');
            app.CurrentGraphic=line(app.Axes,'XData',1,'YData',1,'Color','r',...
                'Marker','x','LineStyle','none','Tag','CurrentPoint');
            app.ReferenceGraphic=line(app.Axes,'XData',[],'YData',[],'Color','r',...
                'Marker','sq','LineStyle','none','Tag','ReferencePoint');
            app.DataGraphic=line(app.Axes,'XData',[],'YData',[],'Color','b',...
                'Marker','sq','LineStyle','none','Tag','DataPoint');
            set([app.CurrentGraphic app.ReferenceGraphic app.DataGraphic],...
                'MarkerSize',10);
            set(app.Marker10,'Checked','on');
            app.StoredList.UserData=nan(0,4);
            %
            temp=[...
                app.mLabel app.mEdit app.nLabel app.nEdit...
                app.xLabel app.xEdit app.yLabel app.yEdit...
                app.StorePoint];
            app.CurrentPanel.Children=temp(end:-1:1);
            app.mEdit.UserData='1.00';
            app.nEdit.UserData='1.00';
            set([app.Axes.XLabel app.Axes.YLabel],'FontAngle','italic');
            %
            movegui(app.UIFigure,'center');
            figure(app.UIFigure);
            app.MinSize=app.UIFigure.Position(3:4);
            %
            app.SessionObject=datninja.Session();
        end

        % Menu selected function: LoadGraphicMenu
        function LoadGraphicSelected(app, event)
            if ~isdeployed
                app.UIFigure.Visible='off';
            end
            try
                loadImage(app.SessionObject);
            catch
                return
            end
            updateImage(app)
        end

        % Key press function: UIFigure
        function UIFigureKeyPress(app, event)
            modifier=event.Modifier;
            switch numel(modifier)
                case 0
                    % keep going
                case 1
                    if strcmpi(modifier,'alt') || strcmpi(modifier,'control')
                        return
                    end
                otherwise
                    return
            end
            key = event.Key;
            if ~ischar(key)
                return
            end
            PanFactor=0.10;
            ZoomFactor=2.00;
            switch lower(key)
                case 's'
                    if strcmpi(modifier,'shift')
                        
                    else
                        StorePointPushed(app,[])
                    end
                case 'a'
                    axis(app.Axes,'auto');
                case 't'
                    axis(app.Axes,'tight');
                    return
                case 'leftarrow'
                    bound=app.Axes.XLim;
                    width=bound(2)-bound(1);
                    if strcmpi(modifier,'shift')
                        center=(bound(1)+bound(2))/2;
                        bound=center+width*ZoomFactor.*[-0.5 0.5];
                    else
                        bound=bound-width*PanFactor;
                    end
                    app.Axes.XLim=bound;
                case 'rightarrow'
                    bound=app.Axes.XLim;
                    width=bound(2)-bound(1);
                    if strcmpi(modifier,'shift')
                        center=(bound(1)+bound(2))/2;
                        bound=center+width/ZoomFactor.*[-0.5 0.5];
                    else
                        bound=bound+width*PanFactor;
                    end
                    app.Axes.XLim=bound;
                case 'downarrow'
                    bound=app.Axes.YLim;
                    width=bound(2)-bound(1);
                    if strcmpi(modifier,'shift')
                        center=(bound(1)+bound(2))/2;
                        bound=center+width*ZoomFactor.*[-0.5 0.5];
                    elseif strcmpi(app.Axes.YDir,'normal')
                        bound=bound-width*PanFactor;
                    else
                        bound=bound+width*PanFactor;
                    end
                    app.Axes.YLim=bound;
                case 'uparrow'
                    bound=app.Axes.YLim;
                    width=bound(2)-bound(1);
                    if strcmpi(modifier,'shift')
                        center=(bound(1)+bound(2))/2;
                        bound=center+width/ZoomFactor.*[-0.5 0.5];
                    elseif strcmpi(app.Axes.YDir,'normal')
                        bound=bound+width*PanFactor;
                    else
                        bound=bound-width*PanFactor;
                    end
                    app.Axes.YLim=bound;
            end
            
        end

        % Window button down function: UIFigure
        function UIFigureWindowButtonDown(app, event)
            MousePos=app.UIFigure.CurrentPoint;
            AxesPos=app.Axes.InnerPosition;
            % make sure click falls inside axes
            if (MousePos(1) < AxesPos(1)) || (MousePos(1) > AxesPos(1)+AxesPos(3))
                return
            elseif (MousePos(2) < AxesPos(2)) || (MousePos(2) > AxesPos(2)+AxesPos(4))
                return
            end
            % convert screen location to image coordinates
            m=(MousePos(1)-AxesPos(1))/AxesPos(3);
            n=(MousePos(2)-AxesPos(2))/AxesPos(4);
            %disp([m n]);
            bound=app.Axes.XLim;
            m=bound(1)+m*(bound(2)-bound(1));
            bound=app.Axes.YLim;
            if strcmpi(app.Axes.YDir,'normal')
                n=bound(1)+n*(bound(2)-bound(1));
            else
                n=bound(2)-n*(bound(2)-bound(1));
            end
            % round pixel coordinates to format resolution
            m=sscanf(sprintf(app.PixelFormat,m),'%g');
            n=sscanf(sprintf(app.PixelFormat,n),'%g');
            %
            app.mEdit.Value=sprintf(app.PixelFormat,m);
            app.mEdit.UserData=app.mEdit.Value;
            app.nEdit.Value=sprintf(app.PixelFormat,n);
            app.nEdit.UserData=app.nEdit.Value;
            % update graphics
            set(app.CurrentGraphic,'XData',m,'YData',n,'Visible','on');
            if app.ReferenceButton.Value
                app.CurrentGraphic.Color=app.ReferenceButton.FontColor;
            elseif app.DataButton.Value
                app.CurrentGraphic.Color=app.DataButton.FontColor;
                temp=[1 m n]*app.SessionObject.ParameterMatrix;
                switch app.SessionObject.LogScaling
                    case 'horizontal'
                        temp(:,1)=10.^temp(:,1);
                    case 'vertical'
                        temp(:,2)=10.^temp(:,2);
                    case 'both'
                        temp=10.^temp;
                end
                app.xEdit.Value=sprintf(app.XDataFormat,temp(1));
                app.xEdit.UserData=app.xEdit.Value;
                app.yEdit.Value=sprintf(app.YDataFormat,temp(2));
                app.yEdit.UserData=app.yEdit.Value;
            end
        end

        % Menu selected function: StartOver
        function StartOverMenuSelected(app, event)
            name=class(app);
            delete(app);
            feval(name);
        end

        % Menu selected function: ReferenceColor
        function ReferenceColorSelected(app, event)
            choice=uisetcolor();
            if isscalar(choice)
                return
            end
            app.ReferenceButton.FontColor=choice;
            app.ReferenceGraphic.Color=choice;
            if app.ReferenceButton.Value
                app.CurrentGraphic.Color=choice;
                app.StoredList.FontColor=choice;
            end
            figure(app.UIFigure);
        end

        % Menu selected function: Marker5
        function Marker5Selected(app, event)
            app.chooseMarkerSize(5);
            app.Marker5.Checked='on';
        end

        % Menu selected function: Marker10
        function Marker10Selected(app, event)
            app.chooseMarkerSize(10);
            app.Marker10.Checked='on';
        end

        % Menu selected function: Marker15
        function Marker15Selected(app, event)
            app.chooseMarkerSize(15);
            app.Marker15.Checked='on';
        end

        % Menu selected function: Marker20
        function Marker20Selected(app, event)
            app.chooseMarkerSize(20);
            app.Marker20.Checked='on';
        end

        % Menu selected function: Marker25
        function Marker25Selected(app, event)
            app.chooseMarkerSize(25);
            app.Marker25.Checked='on';
        end

        % Value changed function: mEdit
        function mEditValueChanged(app, event)
            value = sscanf(app.mEdit.Value,'%g',1);
            if isempty(value)
                app.mEdit.Value=app.mEdit.UserData;
            else
                app.mEdit.Value=sprintf(app.PixelFormat,value);
                app.mEdit.UserData=app.mEdit.Value;
                app.CurrentGraphic.XData=value;
            end
            app.CurrentGraphic.Visible='on';
            if app.DataButton.Value
                
            end
        end

        % Value changed function: nEdit
        function nEditValueChanged(app, event)
            value = sscanf(app.nEdit.Value,'%g',1);
            if isempty(value)
                app.nEdit.Value=app.nEdit.UserData;
            else
                app.nEdit.Value=sprintf(app.PixelFormat,value);
                app.nEdit.UserData=app.nEdit.Value;
                app.CurrentGraphic.YData=value;
            end
            app.CurrentGraphic.Visible='on';
        end

        % Value changed function: xEdit
        function xEditValueChanged(app, event)
            if isempty(app.xEdit.UserData)
                app.xEdit.UserData='';
            end
            [value,app.XDataFormat]=parseData(app.xEdit.Value,app.XDataFormat);
            if isempty(value) || isinf(value) || isnan(value)
                app.xEdit.Value=app.xEdit.UserData;
            else
                app.xEdit.Value=sprintf(app.XDataFormat,value);
                app.xEdit.UserData=app.xEdit.Value;
            end
        end

        % Value changed function: yEdit
        function yEditValueChanged(app, event)
            if isempty(app.yEdit.UserData)
                app.yEdit.UserData='';
            end
            [value,app.YDataFormat]=parseData(app.yEdit.Value,app.YDataFormat);
            if isempty(value) || isinf(value) || isnan(value)
                app.yEdit.Value=app.yEdit.UserData;
            else
                app.yEdit.Value=sprintf(app.YDataFormat,value);
                app.yEdit.UserData=app.yEdit.Value;
            end
        end

        % Menu selected function: DataColor
        function DataColorSelected(app, event)
            choice=uisetcolor();
            if isscalar(choice)
                return
            end
            app.DataButton.FontColor=choice;
            app.DataGraphic.Color=choice;
            if app.DataButton.Value
                app.CurrentGraphic.Color=choice;
                app.StoredList.FontColor=choice;
            end
            figure(app.UIFigure);
        end

        % Button pushed function: StorePoint
        function StorePointPushed(app, event)
            if ~PointReady(app)
                return
            end
            % grab current point
            data=app.StoredList.UserData;
            if strcmpi(app.StoredList.Enable,'on')
                list=app.StoredList.Items;
            else
                list={};
                app.StoredList.Enable='on';
            end
            index=numel(list)+1;
            list{index}=sprintf('Point %d',index);
            app.StoredList.Items=list;
            pause(0.1); % let figure catch up with list update
            app.StoredList.Value=list{end};
            scroll(app.StoredList,'bottom');
            data(index,4)=sscanf(app.yEdit.Value,'%g',1);
            data(index,3)=sscanf(app.xEdit.Value,'%g',1);
            data(index,2)=sscanf(app.nEdit.Value,'%g',1);
            data(index,1)=sscanf(app.mEdit.Value,'%g',1);
            updatePoints(app,data);
        end

        % Button pushed function: MovePoint
        function MovePointPushed(app, event)
            if ~PointReady(app) || strcmp(app.StoredList.Enable,'off')
                return
            end
            % update selection to match current point
            value = app.StoredList.Value;
            index=sscanf(value,'Point %d');
            data=app.StoredList.UserData;
            data(index,4)=sscanf(app.yEdit.Value,'%g',1);
            data(index,3)=sscanf(app.xEdit.Value,'%g',1);
            data(index,2)=sscanf(app.nEdit.Value,'%g',1);
            data(index,1)=sscanf(app.mEdit.Value,'%g',1);
            app.StoredList.UserData=data;
            updatePoints(app,data);
        end

        % Value changed function: StoredList
        function StoredListChanged(app, event)
            value = app.StoredList.Value;
            index=sscanf(value,'Point %d');
            data=app.StoredList.UserData(index,:);
            set(app.CurrentGraphic,'XData',data(1),'YData',data(2));
            temp=sprintf(app.PixelFormat,data(1));
            set(app.mEdit,'Value',temp,'UserData',temp);
            temp=sprintf(app.PixelFormat,data(2));
            set(app.nEdit,'Value',temp,'UserData',temp);
            temp=sprintf(app.XDataFormat,data(3));
            set(app.xEdit,'Value',temp,'UserData',temp);
            temp=sprintf(app.YDataFormat,data(4));
            set(app.yEdit,'Value',temp,'UserData',temp);
        end

        % Button pushed function: RemovePoint
        function RemovePointPushed(app, event)
            if strcmp(app.StoredList.Enable,'off')
                return
            end
            list=app.StoredList.Items;
            value=app.StoredList.Value;
            index=sscanf(value,'Point %d');
            keep=[1:(index-1) (index+1):numel(list)];
            data=app.StoredList.UserData;
            if isempty(keep)
                set(app.StoredList,'Items',{'(none)'},'Value','(none)','Enable','off')
                data=nan(0,4);
            else
                list=cell(size(keep));
                for k=1:numel(keep)
                    list{k}=sprintf('Point %d',k);
                end
                app.StoredList.Items=list;
                app.StoredList.Value=sprintf('Point %d',max(index-1,1));
                data=data(keep,:);
            end
            updatePoints(app,data);
        end

        % Button pushed function: PromotePoint
        function PromotePointPushed(app, event)
            if strcmp(app.StoredList.Enable,'off')
                return
            end
            list=app.StoredList.Items;
            if numel(list) == 1
                return
            end
            value=app.StoredList.Value;
            index=sscanf(value,'Point %d');
            if index == 1
                return
            end
            data=app.StoredList.UserData;
            data([index-1 index],:)=data([index index-1],:);
            updatePoints(app,data);
            temp=sprintf('Point %d',index-1);
            app.StoredList.Value=temp;
            scroll(app.StoredList,temp);
        end

        % Button pushed function: DemotePoint
        function DemotePointPushed(app, event)
            if strcmp(app.StoredList.Enable,'off')
                return
            end
            list=app.StoredList.Items;
            if numel(list) == 1
                return
            end
            value=app.StoredList.Value;
            index=sscanf(value,'Point %d');
            if index == numel(list)
                return
            end
            data=app.StoredList.UserData;
            data([index+1 index],:)=data([index index+1],:);
            updatePoints(app,data);
            temp=sprintf('Point %d',index+1);
            app.StoredList.Value=temp;
            scroll(app.StoredList,temp);
        end

        % Menu selected function: LeftMenu
        function LeftMenuSelected(app, event)
            rotateImage(app.SessionObject,'left');
            updateImage(app);
        end

        % Menu selected function: RightMenu
        function RightMenuSelected(app, event)
            
            rotateImage(app.SessionObject,'right');
            updateImage(app);
        end

        % Menu selected function: VerticalMenu
        function VerticalMenuSelected(app, event)
            flipImage(app.SessionObject,'vertical');
            updateImage(app);
        end

        % Menu selected function: HorizontalMenu
        function HorizontalMenuSelected(app, event)
            flipImage(app.SessionObject,'horizontal');
            updateImage(app);
        end

        % Selection changed function: SelectionModePanel
        function SelectionModePanelSelectionChanged(app, event)
            if app.ReferenceButton.Value
                app.ReferenceGraphic.Visible='on';
                app.DataGraphic.Visible='off';
                app.CurrentGraphic.Color=app.ReferenceGraphic.Color;
                app.StoredList.UserData=app.SessionObject.ReferenceTable;
                app.StoredList.FontColor=app.ReferenceGraphic.Color;
                M=size(app.SessionObject.ReferenceTable,1);
                app.mEdit.Enable='on';
                app.nEdit.Enable='on';
                app.xEdit.Enable='on';
                app.yEdit.Enable='on';
            elseif app.DataButton.Value
                analyzeData(app.SessionObject);
                app.ReferenceGraphic.Visible='off';
                app.DataGraphic.Visible='on';
                app.CurrentGraphic.Color=app.DataGraphic.Color;
                app.StoredList.UserData=app.SessionObject.DataTable;
                app.StoredList.FontColor=app.DataGraphic.Color;
                M=size(app.SessionObject.DataTable,1);
                app.mEdit.Enable='off';
                app.nEdit.Enable='off';
                app.xEdit.Enable='off';
                app.yEdit.Enable='off';
            end
            if M == 0
                set(app.StoredList,'Items',{'(none)'},'Value','(none)','Enable','off');
            else
                list=cell(M,1);
                for m=1:M
                    list{m}=sprintf('Point %d',m);
                end
                set(app.StoredList,'Items',list,'Value','Point 1','Enable','on');
            end
        end

        % Menu selected function: LogNone
        function LogNoneSelected(app, event)
            app.SessionObject.LogScaling='none';
            set(app.LogScalingMenu.Children,'Checked','off');
            set(app.LogNone,'Checked','on');
            try
                analyzeReference(app.SessionObject);
                analyzeData(app.SessionObject);
            catch
            end
        end

        % Menu selected function: LogHorizontal
        function LogHorizontalMenuSelected(app, event)
            app.SessionObject.LogScaling='horizontal';
            set(app.LogScalingMenu.Children,'Checked','off');
            set(app.LogHorizontal,'Checked','on');
            try
                analyzeReference(app.SessionObject);
                analyzeData(app.SessionObject);
            catch
            end
        end

        % Menu selected function: LogVertical
        function LogVerticalMenuSelected(app, event)
            app.SessionObject.LogScaling='vertical';
            set(app.LogScalingMenu.Children,'Checked','off');
            set(app.LogVertical,'Checked','on');
            try
                analyzeReference(app.SessionObject);
                analyzeData(app.SessionObject);
            catch
            end
        end

        % Menu selected function: LogBoth
        function LogBothMenuSelected(app, event)
            app.SessionObject.LogScaling='both';
            set(app.LogScalingMenu.Children,'Checked','off');
            set(app.LogBoth,'Checked','on');
            try
                analyzeReference(app.SessionObject);
                analyzeData(app.SessionObject);
            catch
            end
        end

        % Menu selected function: ExportData
        function ExportDataMenuSelected(app, event)
            export(app.SessionObject,'',[app.XDataFormat ' ' app.YDataFormat]);
            figure(app.UIFigure);
        end

        % Menu selected function: SaveCurrent
        function SaveCurrentMenuSelected(app, event)
            store(app.SessionObject);
            figure(app.UIFigure);
        end

        % Menu selected function: LoadPrevious
        function LoadPreviousMenuSelected(app, event)
            
            [file,location]=uigetfile({'*.sda' 'Sandia Data Archive (*.sda) files'},...
                'Select session file');
            if isnumeric(file)
                return
            end
            file=fullfile(location,file);
            app.SessionObject=SMASH.FileAccess.readFile(file,'sda','datninja session');
            updateImage(app);
            % update reference and data graphics
            if app.ReferenceButton.Value                
                updatePoints(app,app.SessionObject.ReferenceTable);
                app.ReferenceButton.Value=0;
                app.DataButton.Value=1;
                updatePoints(app,app.SessionObject.DataTable);
                app.DataGraphic.Visible='off';
                app.ReferenceButton.Value=1;
                app.DataButton.Value=0;
            elseif app.DataButton.Value
                updatePoints(app,app.SessionObject.DataTable);
                app.ReferenceButton.Value=1;
                app.DataButton.Value=0;
                updatePoints(app,app.SessionObject.ReferenceTable);
                app.ReferenceGraphic.Visible='off';
                app.ReferenceButton.Value=0;
                app.DataButton.Value=1;
            end
            SelectionModePanelSelectionChanged(app);
        end

        % Menu selected function: Marker50
        function Marker50MenuSelected(app, event)
            app.chooseMarkerSize(50);
            app.Marker50.Checked='on';
        end

        % Menu selected function: Marker100
        function Marker100MenuSelected(app, event)
            app.chooseMarkerSize(100);
            app.Marker100.Checked='on';
        end
    end

    % App initialization and construction
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure
            app.UIFigure = uifigure;
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'datninja';
            app.UIFigure.WindowButtonDownFcn = createCallbackFcn(app, @UIFigureWindowButtonDown, true);
            app.UIFigure.KeyPressFcn = createCallbackFcn(app, @UIFigureKeyPress, true);

            % Create SessionMenu
            app.SessionMenu = uimenu(app.UIFigure);
            app.SessionMenu.Text = 'Session';

            % Create StartOver
            app.StartOver = uimenu(app.SessionMenu);
            app.StartOver.MenuSelectedFcn = createCallbackFcn(app, @StartOverMenuSelected, true);
            app.StartOver.Text = 'Start over';

            % Create LoadPrevious
            app.LoadPrevious = uimenu(app.SessionMenu);
            app.LoadPrevious.MenuSelectedFcn = createCallbackFcn(app, @LoadPreviousMenuSelected, true);
            app.LoadPrevious.Separator = 'on';
            app.LoadPrevious.Text = 'Load previous';

            % Create SaveCurrent
            app.SaveCurrent = uimenu(app.SessionMenu);
            app.SaveCurrent.MenuSelectedFcn = createCallbackFcn(app, @SaveCurrentMenuSelected, true);
            app.SaveCurrent.Text = 'Save current';

            % Create ExportData
            app.ExportData = uimenu(app.SessionMenu);
            app.ExportData.MenuSelectedFcn = createCallbackFcn(app, @ExportDataMenuSelected, true);
            app.ExportData.Separator = 'on';
            app.ExportData.Text = 'Export data';

            % Create ImageMenu
            app.ImageMenu = uimenu(app.UIFigure);
            app.ImageMenu.Text = 'Image';

            % Create LoadGraphicMenu
            app.LoadGraphicMenu = uimenu(app.ImageMenu);
            app.LoadGraphicMenu.MenuSelectedFcn = createCallbackFcn(app, @LoadGraphicSelected, true);
            app.LoadGraphicMenu.Text = 'Load file';

            % Create RotateMenu
            app.RotateMenu = uimenu(app.ImageMenu);
            app.RotateMenu.Separator = 'on';
            app.RotateMenu.Text = 'Rotate';

            % Create LeftMenu
            app.LeftMenu = uimenu(app.RotateMenu);
            app.LeftMenu.MenuSelectedFcn = createCallbackFcn(app, @LeftMenuSelected, true);
            app.LeftMenu.Text = 'Left';

            % Create RightMenu
            app.RightMenu = uimenu(app.RotateMenu);
            app.RightMenu.MenuSelectedFcn = createCallbackFcn(app, @RightMenuSelected, true);
            app.RightMenu.Text = 'Right';

            % Create FlipMenu
            app.FlipMenu = uimenu(app.ImageMenu);
            app.FlipMenu.Text = 'Flip';

            % Create VerticalMenu
            app.VerticalMenu = uimenu(app.FlipMenu);
            app.VerticalMenu.MenuSelectedFcn = createCallbackFcn(app, @VerticalMenuSelected, true);
            app.VerticalMenu.Text = 'Vertical';

            % Create HorizontalMenu
            app.HorizontalMenu = uimenu(app.FlipMenu);
            app.HorizontalMenu.MenuSelectedFcn = createCallbackFcn(app, @HorizontalMenuSelected, true);
            app.HorizontalMenu.Text = 'Horizontal';

            % Create LogScalingMenu
            app.LogScalingMenu = uimenu(app.ImageMenu);
            app.LogScalingMenu.Text = 'Log scaling';

            % Create LogNone
            app.LogNone = uimenu(app.LogScalingMenu);
            app.LogNone.MenuSelectedFcn = createCallbackFcn(app, @LogNoneSelected, true);
            app.LogNone.Checked = 'on';
            app.LogNone.Text = 'None';

            % Create LogHorizontal
            app.LogHorizontal = uimenu(app.LogScalingMenu);
            app.LogHorizontal.MenuSelectedFcn = createCallbackFcn(app, @LogHorizontalMenuSelected, true);
            app.LogHorizontal.Text = 'Horizontal';

            % Create LogVertical
            app.LogVertical = uimenu(app.LogScalingMenu);
            app.LogVertical.MenuSelectedFcn = createCallbackFcn(app, @LogVerticalMenuSelected, true);
            app.LogVertical.Text = 'Vertical';

            % Create LogBoth
            app.LogBoth = uimenu(app.LogScalingMenu);
            app.LogBoth.MenuSelectedFcn = createCallbackFcn(app, @LogBothMenuSelected, true);
            app.LogBoth.Text = 'Both';

            % Create MarkerMenu
            app.MarkerMenu = uimenu(app.UIFigure);
            app.MarkerMenu.Text = 'Marker';

            % Create SizeMenu
            app.SizeMenu = uimenu(app.MarkerMenu);
            app.SizeMenu.Text = 'Size';

            % Create Marker5
            app.Marker5 = uimenu(app.SizeMenu);
            app.Marker5.MenuSelectedFcn = createCallbackFcn(app, @Marker5Selected, true);
            app.Marker5.Text = '5 points';

            % Create Marker10
            app.Marker10 = uimenu(app.SizeMenu);
            app.Marker10.MenuSelectedFcn = createCallbackFcn(app, @Marker10Selected, true);
            app.Marker10.Text = '10 points';

            % Create Marker15
            app.Marker15 = uimenu(app.SizeMenu);
            app.Marker15.MenuSelectedFcn = createCallbackFcn(app, @Marker15Selected, true);
            app.Marker15.Text = '15 points';

            % Create Marker20
            app.Marker20 = uimenu(app.SizeMenu);
            app.Marker20.MenuSelectedFcn = createCallbackFcn(app, @Marker20Selected, true);
            app.Marker20.Text = '20 points';

            % Create Marker25
            app.Marker25 = uimenu(app.SizeMenu);
            app.Marker25.MenuSelectedFcn = createCallbackFcn(app, @Marker25Selected, true);
            app.Marker25.Text = '25 points';

            % Create Marker50
            app.Marker50 = uimenu(app.SizeMenu);
            app.Marker50.MenuSelectedFcn = createCallbackFcn(app, @Marker50MenuSelected, true);
            app.Marker50.Text = '50 points';

            % Create Marker100
            app.Marker100 = uimenu(app.SizeMenu);
            app.Marker100.MenuSelectedFcn = createCallbackFcn(app, @Marker100MenuSelected, true);
            app.Marker100.Text = '100 points';

            % Create ColorMenu
            app.ColorMenu = uimenu(app.MarkerMenu);
            app.ColorMenu.Text = 'Color';

            % Create ReferenceColor
            app.ReferenceColor = uimenu(app.ColorMenu);
            app.ReferenceColor.MenuSelectedFcn = createCallbackFcn(app, @ReferenceColorSelected, true);
            app.ReferenceColor.Text = 'Reference';

            % Create DataColor
            app.DataColor = uimenu(app.ColorMenu);
            app.DataColor.MenuSelectedFcn = createCallbackFcn(app, @DataColorSelected, true);
            app.DataColor.Text = 'Data';

            % Create CurrentPanel
            app.CurrentPanel = uipanel(app.UIFigure);
            app.CurrentPanel.Title = 'Current location :';
            app.CurrentPanel.FontWeight = 'bold';
            app.CurrentPanel.FontSize = 14;
            app.CurrentPanel.Position = [12 346 169 165];

            % Create yLabel
            app.yLabel = uilabel(app.CurrentPanel);
            app.yLabel.HorizontalAlignment = 'right';
            app.yLabel.FontSize = 14;
            app.yLabel.FontAngle = 'italic';
            app.yLabel.Position = [1 35 25 22];
            app.yLabel.Text = 'y=';

            % Create yEdit
            app.yEdit = uieditfield(app.CurrentPanel, 'text');
            app.yEdit.ValueChangedFcn = createCallbackFcn(app, @yEditValueChanged, true);
            app.yEdit.FontSize = 14;
            app.yEdit.Tooltip = {'Vertical data value'};
            app.yEdit.Position = [33 35 112 22];
            app.yEdit.Value = '+0.000';

            % Create mLabel
            app.mLabel = uilabel(app.CurrentPanel);
            app.mLabel.HorizontalAlignment = 'right';
            app.mLabel.FontSize = 14;
            app.mLabel.FontAngle = 'italic';
            app.mLabel.Position = [1 109 26 22];
            app.mLabel.Text = 'm=';

            % Create mEdit
            app.mEdit = uieditfield(app.CurrentPanel, 'text');
            app.mEdit.ValueChangedFcn = createCallbackFcn(app, @mEditValueChanged, true);
            app.mEdit.FontSize = 14;
            app.mEdit.Tooltip = {'Horizontal pixel value'};
            app.mEdit.Position = [33 109 112 22];
            app.mEdit.Value = '1.00';

            % Create nLabel
            app.nLabel = uilabel(app.CurrentPanel);
            app.nLabel.HorizontalAlignment = 'right';
            app.nLabel.FontSize = 14;
            app.nLabel.FontAngle = 'italic';
            app.nLabel.Position = [1 85 25 22];
            app.nLabel.Text = 'n=';

            % Create nEdit
            app.nEdit = uieditfield(app.CurrentPanel, 'text');
            app.nEdit.ValueChangedFcn = createCallbackFcn(app, @nEditValueChanged, true);
            app.nEdit.FontSize = 14;
            app.nEdit.Tooltip = {'Vertical pixel value'};
            app.nEdit.Position = [33 85 112 22];
            app.nEdit.Value = '1.00';

            % Create xLabel
            app.xLabel = uilabel(app.CurrentPanel);
            app.xLabel.HorizontalAlignment = 'right';
            app.xLabel.FontSize = 14;
            app.xLabel.FontAngle = 'italic';
            app.xLabel.Position = [1 59 25 22];
            app.xLabel.Text = 'x=';

            % Create xEdit
            app.xEdit = uieditfield(app.CurrentPanel, 'text');
            app.xEdit.ValueChangedFcn = createCallbackFcn(app, @xEditValueChanged, true);
            app.xEdit.FontSize = 14;
            app.xEdit.Tooltip = {'Horizontal data value'};
            app.xEdit.Position = [33 59 112 22];
            app.xEdit.Value = '+0.000';

            % Create StorePoint
            app.StorePoint = uibutton(app.CurrentPanel, 'push');
            app.StorePoint.ButtonPushedFcn = createCallbackFcn(app, @StorePointPushed, true);
            app.StorePoint.FontSize = 14;
            app.StorePoint.Tooltip = {'Store current point as a new selection (same as pressing "s" key)'};
            app.StorePoint.Position = [33 8 110 24];
            app.StorePoint.Text = 'Store point';

            % Create StoredPanel
            app.StoredPanel = uipanel(app.UIFigure);
            app.StoredPanel.Title = 'Stored points:';
            app.StoredPanel.FontWeight = 'bold';
            app.StoredPanel.FontSize = 14;
            app.StoredPanel.Position = [13 18 168 317];

            % Create StoredList
            app.StoredList = uilistbox(app.StoredPanel);
            app.StoredList.Items = {'(none)'};
            app.StoredList.ValueChangedFcn = createCallbackFcn(app, @StoredListChanged, true);
            app.StoredList.Enable = 'off';
            app.StoredList.FontColor = [1 0 0];
            app.StoredList.Position = [3 13 77 272];
            app.StoredList.Value = {};

            % Create MovePoint
            app.MovePoint = uibutton(app.StoredPanel, 'push');
            app.MovePoint.ButtonPushedFcn = createCallbackFcn(app, @MovePointPushed, true);
            app.MovePoint.FontSize = 14;
            app.MovePoint.Tooltip = {'Move selection to current location'};
            app.MovePoint.Position = [89 261 65 24];
            app.MovePoint.Text = 'Move';

            % Create RemovePoint
            app.RemovePoint = uibutton(app.StoredPanel, 'push');
            app.RemovePoint.ButtonPushedFcn = createCallbackFcn(app, @RemovePointPushed, true);
            app.RemovePoint.FontSize = 14;
            app.RemovePoint.Tooltip = {'Remove selection'};
            app.RemovePoint.Position = [89 226 65 24];
            app.RemovePoint.Text = 'Remove';

            % Create PromotePoint
            app.PromotePoint = uibutton(app.StoredPanel, 'push');
            app.PromotePoint.ButtonPushedFcn = createCallbackFcn(app, @PromotePointPushed, true);
            app.PromotePoint.FontSize = 14;
            app.PromotePoint.Tooltip = {'Shift selection upward'};
            app.PromotePoint.Position = [89 146 65 24];
            app.PromotePoint.Text = 'Promote';

            % Create DemotePoint
            app.DemotePoint = uibutton(app.StoredPanel, 'push');
            app.DemotePoint.ButtonPushedFcn = createCallbackFcn(app, @DemotePointPushed, true);
            app.DemotePoint.FontSize = 14;
            app.DemotePoint.Tooltip = {'Shift selection downward'};
            app.DemotePoint.Position = [89 114 65 24];
            app.DemotePoint.Text = 'Demote';

            % Create SelectionModePanel
            app.SelectionModePanel = uibuttongroup(app.UIFigure);
            app.SelectionModePanel.SelectionChangedFcn = createCallbackFcn(app, @SelectionModePanelSelectionChanged, true);
            app.SelectionModePanel.Title = 'Selection mode:';
            app.SelectionModePanel.FontWeight = 'bold';
            app.SelectionModePanel.FontSize = 14;
            app.SelectionModePanel.Position = [12 520 169 71];

            % Create ReferenceButton
            app.ReferenceButton = uiradiobutton(app.SelectionModePanel);
            app.ReferenceButton.Text = 'Reference';
            app.ReferenceButton.FontSize = 14;
            app.ReferenceButton.FontColor = [1 0 0];
            app.ReferenceButton.Position = [11 22 86 22];
            app.ReferenceButton.Value = true;

            % Create DataButton
            app.DataButton = uiradiobutton(app.SelectionModePanel);
            app.DataButton.Enable = 'off';
            app.DataButton.Text = 'Data';
            app.DataButton.FontSize = 14;
            app.DataButton.FontColor = [0 0 1];
            app.DataButton.Position = [11 0 51 22];

            % Create Axes
            app.Axes = uiaxes(app.UIFigure);
            title(app.Axes, '')
            xlabel(app.Axes, '')
            ylabel(app.Axes, '')
            app.Axes.Box = 'on';
            app.Axes.BoxStyle = 'full';
            app.Axes.YAxisLocation = 'right';
            app.Axes.Position = [196 24 593 510];

            % Create UsekeyboardarrowtoLabel
            app.UsekeyboardarrowtoLabel = uilabel(app.UIFigure);
            app.UsekeyboardarrowtoLabel.FontSize = 14;
            app.UsekeyboardarrowtoLabel.Position = [322 543 342 48];
            app.UsekeyboardarrowtoLabel.Text = {'Press arrow key for pan and shift-arrow key for zoom'; 'Press ''a'' for auto scaling and ''t'' for tight scaling'; 'Press ''s'' to store current location'};
        end
    end

    methods (Access = public)

        % Construct app
        function app = datninja

            % Create and configure components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
