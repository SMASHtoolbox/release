function db=createGUI(FontSize)

%%
PixelFormat='%.3f';
VariableFormat='%+#.6g';

session=datninja.Session();

%% mock up dialog box
db=SMASH.MUI.DialogPlot('FontSize',FontSize);
set(db.Figure,'IntegerHandle','off','HandleVisibility','callback',...
    'Visible','off');
db.Name='dataninja 2.0';
db.Hidden=true;
setappdata(db.Figure,'Session',session);

spacer(1)=addblock(db,'text','junk',20);

h=addblock(db,'text','Reference point:');
set(h,'FontWeight','bold','Tag','PointLabel');
h=addblock(db,'cedit','m=',[5 10]);
set(h(end),'Tag','mEdit');
h=addblock(db,'cedit','n=',[5 10]);
set(h(end),'Tag','nEdit');
h=addblock(db,'cedit','x=',[5 10]);
set(h(end),'Tag','xEdit');
hA=addblock(db,'cedit','y=',[5 10]);
set(hA(end),'Tag','yEdit');

hB=addblock(db,'button','Store',10);
set(hB,'Tag','StorePoint');

hList=addblock(db,'listbox','Stored points:',{''},15,20);
set(hList(1),'FontWeight','bold');
set(hList(2),'String',{'(none)'},'Enable','off','Tag','StoredPoints');

h=addblock(db,'button',{'Update' 'Remove'});
set(h(1),'Tag','Update');
set(h(2),'Tag','Remove');

spacer(2)=addblock(db,'text','junk',20);

finish(db);
delete(spacer);

posA=getpixelposition(hA(2));
posB=getpixelposition(hB);
posB(1)=posA(1);
posB(3)=posA(3);
setpixelposition(hB,posB);

%% port controls to tabs
h=get(db.ControlPanel,'Children');

hTabGroup=uitabgroup('Parent',db.ControlPanel,'TabLocation','bottom',...
    'SelectionChangedFcn',@changeTab);
    function changeTab(varargin)
        switch varargin{2}.NewValue
            case hTab(1)
                data=session.ReferenceTable;
                hEdit=[hReference.mEdit hReference.nEdit ...
                    hReference.xEdit hReference.yEdit];
                hList=hReference.StoredPoints;
            case hTab(2)
                try
                    analyzeReference(session);
                    analyzeData(session);
                catch
                end
                data=session.DataTable;
                hEdit=[hData.mEdit hData.nEdit ...
                    hData.xEdit hData.yEdit];
                hList=hData.StoredPoints;
        end
        if isempty(data)
            set(hSelectedPoints,'XData',[],'YData',[]);
            set(hList,'String','(none)','Value',1,'Enable','off');
        else
            set(hSelectedPoints,'XData',data(:,1),'YData',data(:,2));
            list=cell(size(data,1),1);
            for k=1:numel(list)
                list{k}=sprintf('Point %d',k);
            end
            set(hList,'String',list,'Value',1,'Enable','on');
        end
        set(hEdit,'String','');
        set(hCurrentPoint,'XData',[],'YData',[]);
    end
hTab(1)=uitab(hTabGroup,'Title','Reference','Tag','Reference');
set(h,'Parent',hTab(1));

hTab(2)=uitab(hTabGroup,'Title','Data','Tag','Data');
copyobj(h,hTab(2));

for m=1:numel(hTab)
    children=get(hTab(m),'Children');
    set(hTab(m),'Children',children(end:-1:1));
end

hReference=SMASH.MUI.findTags(hTab(1));
hData=SMASH.MUI.findTags(hTab(2));
set(hData.PointLabel,'String','Data point:');

set([hReference.mEdit hReference.nEdit hData.mEdit hData.nEdit],...
    'Callback',@updateMN)
    function updateMN(src,varargin)
        new=sscanf(src.String,'%f',1);
        if isempty(new)
            src.String='';
            set(hCurrentPoint,'XData',nan,'YData',nan);
            return
        end
        new=sprintf('%.3f',new);
        set(src,'String',new);
        new=sscanf(new,'%g');
        switch src.Tag
            case 'mEdit'
                set(hCurrentPoint,'XData',new);
            case 'nEdit'
                set(hCurrentPoint,'YData',new);
        end
        if strcmpi(src.Parent.Tag,'Data')
            if isempty(session.ParameterMatrix)
                set([hData.xEdit hData.yEdit],'String','');
            else
                Q=ones(1,3);
                Q(2)=sscanf(hData.mEdit.String,'%g',1);
                Q(3)=sscanf(hData.nEdit.String,'%g',1);
                Q=Q*session.ParameterMatrix;
                hData.xEdit.String=sprintf(VariableFormat,Q(1));
                hData.yEdit.String=sprintf(VariableFormat,Q(2));
            end
        end
    end

set([hData.xEdit hData.yEdit],'Enable','off');
set([hReference.xEdit hReference.yEdit],...
    'Callback',@updateXY)
    function updateXY(src,varargin)
        new=sscanf(src.String,'%g',1);
        if isempty(new)
            set(src.String,'');
            return
        end
        new=sprintf(VariableFormat,new);
        set(src,'String',new);
    end

set(hReference.StorePoint,'Callback',@storeReference);
    function storeReference(varargin)
        list=[hReference.mEdit hReference.nEdit hReference.xEdit hReference.yEdit];
        data=nan(size(list));
        for k=1:numel(list)
            temp=get(list(k),'String');
            temp=sscanf(temp,'%g',1);
            if isempty(temp)
                return
            end
            data(k)=temp;
        end
        x=hSelectedPoints.XData;
        x(end+1)=data(1);
        y=hSelectedPoints.YData;
        y(end+1)=data(2);
        set(hSelectedPoints,'XData',x,'YData',y);
        session.ReferenceTable(end+1,:)=data;
        temp=get(hReference.StoredPoints,'String');
        if strcmpi(hReference.StoredPoints.Enable,'on')
            temp{end+1}=sprintf('Point %d',numel(temp)+1);
        else
            temp={'Point 1'};
        end
        set(hReference.StoredPoints,'String',temp,'Value',numel(temp),...
            'Enable','on');
    end

set(hData.StorePoint,'Callback',@storeData,...
    'TooltipString','Press the space bar to quickly store data points');
    function storeData(varargin)
        list=[hData.mEdit hData.nEdit hData.xEdit hData.yEdit];
        data=nan(size(list));
        for k=1:numel(list)
            temp=get(list(k),'String');
            temp=sscanf(temp,'%g',1);
            if ~isempty(temp)
                data(k)=temp;
            end
        end
        x=hSelectedPoints.XData;
        x(end+1)=data(1);
        y=hSelectedPoints.YData;
        y(end+1)=data(2);
        set(hSelectedPoints,'XData',x,'YData',y);
        session.DataTable(end+1,:)=data;
        temp=get(hData.StoredPoints,'String');
        if strcmpi(hData.StoredPoints.Enable,'on')
            temp{end+1}=sprintf('Point %d',numel(temp)+1);
        else
            temp={'Point 1'};
        end
        set(hData.StoredPoints,'String',temp,'Value',numel(temp),...
            'Enable','on');
    end

set(hReference.StoredPoints,'Callback',@selectReference);
    function selectReference(varargin)
        index=get(hReference.StoredPoints,'Value');
        data=session.ReferenceTable(index,:);
        hReference.mEdit.String=sprintf(PixelFormat,data(1));
        updateMN(hReference.mEdit);
        hReference.nEdit.String=sprintf(PixelFormat,data(2));
        updateMN(hReference.nEdit);
        hReference.xEdit.String=sprintf(VariableFormat,data(3));
        hReference.yEdit.String=sprintf(VariableFormat,data(4));
    end

set(hData.StoredPoints,'Callback',@selectData)
    function selectData(varargin)
        index=get(hData.StoredPoints,'Value');
        data=session.DataTable(index,:);
        hData.mEdit.String=sprintf(PixelFormat,data(1));
        hData.nEdit.String=sprintf(PixelFormat,data(2));
        updateMN(hData.mEdit);
        updateMN(hData.nEdit);
        if isnan(data(3))
            hData.xEdit.String='';
            hData.yEdit.String='';
        else
            hData.xEdit.String=sprintf(VariableFormat,data(3));
            hData.yEdit.String=sprintf(VariableFormat,data(4));
        end
    end

set(hReference.Update,'Callback',@updateReference);
    function updateReference(varargin)
        index=get(hReference.StoredPoints,'Value');
        storeReference();
        session.ReferenceTable(index,:)=session.ReferenceTable(end,:);
        session.ReferenceTable=session.ReferenceTable(1:end-1,:);
        list=hReference.StoredPoints.String;
        hReference.StoredPoints.Value=index;
        hReference.StoredPoints.String=list(1:end-1);
        hSelectedPoints.XData=session.ReferenceTable(:,1);
        hSelectedPoints.YData=session.ReferenceTable(:,2);
    end

set(hData.Update,'Callback',@updateData);
    function updateData(varargin)
        index=get(hData.StoredPoints,'Value');
        storeData();
        session.DataTable(index,:)=session.DataTable(end,:);
        session.DataTable=session.DataTable(1:end-1,:);
        list=hData.StoredPoints.String;
        hData.StoredPoints.Value=index;
        hData.StoredPoints.String=list(1:end-1);
        hSelectedPoints.XData=session.DataTable(:,1);
        hSelectedPoints.YData=session.DataTable(:,2);
    end

set(hReference.Remove,'Callback',@removeReference);
    function removeReference(varargin)
        index=get(hReference.StoredPoints,'Value');
        M=size(session.ReferenceTable,1);
        k=[1:index-1 index+1:M];
        session.ReferenceTable=session.ReferenceTable(k,:);
        if numel(k) >= 1
            hReference.StoredPoints.Value=max(index-1,1);
            list=hReference.StoredPoints.String;
            hReference.StoredPoints.String=list(k);
        else
            hReference.StoredPoints.Value=1;
            hReference.StoredPoints.String='(none)';
            hReference.StoredPoints.Enable='off';
        end
        set(hSelectedPoints,...
            'XData',session.ReferenceTable(:,1),...
            'YData',session.ReferenceTable(:,2));
    end

set(hData.Remove,'Callback',@removeData);
    function removeData(varargin)
        index=get(hData.StoredPoints,'Value');
        M=size(session.DataTable,1);
        k=[1:index-1 index+1:M];
        session.DataTable=session.DataTable(k,:);
        if numel(k) >= 1
            hData.StoredPoints.Value=max(index-1,1);
            list=hData.StoredPoints.String;
            hData.StoredPoints.String=list(k);
        else
            hData.StoredPoints.Value=1;
            hData.StoredPoints.String='(none)';
            hData.StoredPoints.Enable='off';
        end
        set(hSelectedPoints,...
            'XData',session.DataTable(:,1),...
            'YData',session.DataTable(:,2));
    end

%% menus
hm=uimenu(db.Figure,'Label','Session');
uimenu(hm,'Label','Change directory','Callback',@changeDirectory);
    function changeDirectory(varargin)
        location=uigetdir(pwd,'Select directory');
        if isnumeric(location)
            return
        end
        cd(location);
    end
uimenu(hm,'Label','Generate examples','Callback',@generateExamples);
    function generateExamples(varargin)
        if strfind(pwd,smashroot) %#ok<STRIFCND>
            errordlg('Cannot create examples inside toolbox directory','Cannot create examples');
            return
        end
        session.generateExamples();
    end
uimenu(hm,'Label','Start over','Callback',@startOver,'Separator','on');
    function startOver(varargin)
        delete(db.Figure);
        createGUI(FontSize);
    end
uimenu(hm,'Label','Load previous','Callback',@loadSession);
    function loadSession(varargin)
        [file,location]=uigetfile({'*.sda' 'Sandia Data Archive (*.sda) files'},...
            'Select session file');
        if isnumeric(file)
            return
        end
        file=fullfile(location,file);
        session=SMASH.FileAccess.readFile(file,'sda','datninja session');
        set(hImage,'CData',session.Image,'Visible','on');
        hTabGroup.SelectedTab=hTab(1);
        data.NewValue=hTab(1);
        changeTab([],data);
    end
uimenu(hm,'Label','Save current','Callback',@saveSession);
    function saveSession(varargin)
        store(session);
    end
sub=uimenu(hm,'Label','Export data');
uimenu(sub,'Label','To file','Callback',@data2file);
    function data2file(varargin)
        export(session)
    end
if isdeployed
    uimenu(sub,'Label','To workspace','Enable','off');
else
    uimenu(sub,'Label','To workspace','Callback',@data2workspace);
end
    function data2workspace(varargin)
        commandwindow();
        fprintf('datninja export data to workspace \n');
        choice=input('   Type variable name: ','s');
        if ~isempty(choice)            
            assignin('base',choice,session.DataTable(:,3:4));
        end
        figure(db.Figure);
    end

uimenu(hm,'Label','Exit','Separator','on','Callback',@exitProgram);
    function exitProgram(varargin)
        delete(db.Figure);
    end

hm=uimenu(db.Figure,'Label','Image');
uimenu(hm,'Label','Load file','Callback',@loadFile);
    function loadFile(varargin)
        loadImage(session);
        set(hImage,'CData',session.Image,'Visible','on');
    end
sub=uimenu(hm,'Label','Rotate','Separator','on');
uimenu(sub,'Label','Clockwise','Callback',@rotateImageMenu);
uimenu(sub,'Label','Counter-clockwise','Callback',@rotateImageMenu);
    function rotateImageMenu(src,varargin)
        switch lower(src.Text)
            case 'clockwise'
                rotateImage(session,'right');                
            otherwise
                rotateImage(session,'left');
        end
        set(hImage,'CData',session.Image);
    end
sub=uimenu(hm,'Label','Flip');
uimenu(sub,'Label','Vertical','Callback',@flipImageMenu);
uimenu(sub,'Label','Horizontal','Callback',@flipImageMenu);
    function flipImageMenu(src,varargin)
        direction=src.Text;
        flipImage(session,direction);
        set(hImage,'CData',session.Image);
    end
hLogScale=uimenu(hm,'Label','Log scaling');
uimenu(hLogScale,'Label','None','Callback',@scaleAxes,'Checked','on');
uimenu(hLogScale,'Label','Horizontal','Callback',@scaleAxes);
uimenu(hLogScale,'Label','Vertical','Callback',@scaleAxes);
uimenu(hLogScale,'Label','Both','Callback',@scaleAxes);
    function scaleAxes(src,varargin)
        set(hLogScale.Children,'Checked','off');
        src.Checked='on';
        session.LogScaling=lower(src.Text);
        try
            analyzeReference(session);
            analyzeData(session);
        catch            
        end
        if hTabGroup.SelectedTab == hTab(2)
            hData.xEdit.String='';
            hData.yEdit.String='';
        end
    end

hm=uimenu(db.Figure,'Label','Marker');
hMarkerSize=uimenu(hm,'Label','Size');
uimenu(hMarkerSize,'Label','5 points','Callback',@changeMarkerSize);
uimenu(hMarkerSize,'Label','10 points','Callback',@changeMarkerSize,'Checked','on');
uimenu(hMarkerSize,'Label','15 points','Callback',@changeMarkerSize);
uimenu(hMarkerSize,'Label','20 points','Callback',@changeMarkerSize);
uimenu(hMarkerSize,'Label','25 points','Callback',@changeMarkerSize);
uimenu(hMarkerSize,'Label','50 points','Callback',@changeMarkerSize);
uimenu(hMarkerSize,'Label','100 points','Callback',@changeMarkerSize);
    function changeMarkerSize(src,varargin)
        set(hMarkerSize.Children,'Checked','off');
        set(src,'Checked','on');
        value=sscanf(src.Text,'%d',1);
        set([hCurrentPoint hSelectedPoints],'MarkerSize',value);
    end
hMarkerColor=uimenu(hm,'Label','Color');
uimenu(hMarkerColor,'Label','Red','Callback',@changeMarkerColor);
uimenu(hMarkerColor,'Label','Green','Callback',@changeMarkerColor);
uimenu(hMarkerColor,'Label','Blue','Callback',@changeMarkerColor);
uimenu(hMarkerColor,'Label','Black','Callback',@changeMarkerColor);
uimenu(hMarkerColor,'Label','Custom','Callback',@changeMarkerColor,...
    'Separator','on');
    function changeMarkerColor(src,varargin)
        switch lower(src.Text)
            case 'red'
                value='r';
            case 'green'
                value='g';
            case 'blue'
                value='b';
            case 'black'
                value='k';
            case 'custom'
                value=uisetcolor();
                if value == 0
                    return
                end
        end
        set([hCurrentPoint hSelectedPoints],'MarkerEdge',value);
        set(hMarkerColor.Children,'Checked','off');
        set(src,'Checked','on');
    end


%% axes
set(db.Axes,'FontSize',FontSize,'Color','none',...
    'ButtonDownFcn',@clickMouse)
label{1}='Press arrow key for pan and shift-arrow key for zoom';
label{2}='Press ''a'' for auto scaling and ''t'' for tight scaling';
title(db.Axes,label);

hImage=image(db.Axes,'Visible','off','ButtonDownFcn',@clickMouse);
hCurrentPoint=line(db.Axes','XData',nan,'YData',nan,'Color','r',...
    'MarkerSize',10,'Marker','x','LineStyle','none');
hSelectedPoints=line(db.Axes,'XData',[],'YData',[],'Color','r',...
    'MarkerSize',10,'Marker','sq','LineStyle','none');
set(db.Axes,'YDir','reverse');
xlabel(db.Axes,'Pixel coordinate m');
ylabel(db.Axes,'Pixel coordinate n');

    function clickMouse(varargin)
        location=get(db.Axes,'CurrentPoint');
        location=location(1,1:2);
        set(hCurrentPoint,'XData',location(1),'YData',location(2));
        value{1}=sprintf(PixelFormat,location(1));
        value{2}=sprintf(PixelFormat,location(2));
        current=hTabGroup.SelectedTab;
        switch current.Tag
            case 'Reference'
                set(hReference.mEdit,'String',value{1},'UserData',value{1});
                set(hReference.nEdit,'String',value{2},'UserData',value{2});
            case 'Data'
                set(hData.mEdit,'String',value{1},'UserData',value{1});
                set(hData.nEdit,'String',value{2},'UserData',value{2});
                if isempty(session.ParameterMatrix)
                    value={'' ''};
                else
                    Q=calculateXY(session,location);
                    value{1}=sprintf(VariableFormat,Q(1));
                    value{2}=sprintf(VariableFormat,Q(2));                                   
                end
                set(hData.xEdit,'String',value{1},'UserData',value{1});
                set(hData.yEdit,'String',value{2},'UserData',value{2});
        end
    end

%% figure
ht=findobj(db.Figure,'Type','uitoolbar');
delete(ht);

pos=getpixelposition(db.Figure);
pos(3)=2*pos(4);
setpixelposition(db.Figure,pos);
movegui(db.Figure,'center');

set(db.Figure,'WindowKeyPressFcn',@pressKey)
    function pressKey(~,event)
        current=get(db.Figure.CurrentObject,'Type');
        if strcmpi(current,'uicontrol')
            return
        end
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
                    %StorePointPushed(app,[])
                end
            case 'a'
                axis(db.Axes,'auto');
            case 't'
                axis(db.Axes,'tight');
                return
            case 'leftarrow'
                bound=db.Axes.XLim;
                width=bound(2)-bound(1);
                if strcmpi(modifier,'shift')
                    center=(bound(1)+bound(2))/2;
                    bound=center+width*ZoomFactor.*[-0.5 0.5];
                else
                    bound=bound-width*PanFactor;
                end
                db.Axes.XLim=bound;
            case 'rightarrow'
                bound=db.Axes.XLim;
                width=bound(2)-bound(1);
                if strcmpi(modifier,'shift')
                    center=(bound(1)+bound(2))/2;
                    bound=center+width/ZoomFactor.*[-0.5 0.5];
                else
                    bound=bound+width*PanFactor;
                end
                db.Axes.XLim=bound;
            case 'downarrow'
                bound=db.Axes.YLim;
                width=bound(2)-bound(1);
                if strcmpi(modifier,'shift')
                    center=(bound(1)+bound(2))/2;
                    bound=center+width*ZoomFactor.*[-0.5 0.5];
                elseif strcmpi(db.Axes.YDir,'normal')
                    bound=bound-width*PanFactor;
                else
                    bound=bound+width*PanFactor;
                end
                db.Axes.YLim=bound;
            case 'uparrow'
                bound=db.Axes.YLim;
                width=bound(2)-bound(1);
                if strcmpi(modifier,'shift')
                    center=(bound(1)+bound(2))/2;
                    bound=center+width/ZoomFactor.*[-0.5 0.5];
                elseif strcmpi(db.Axes.YDir,'normal')
                    bound=bound+width*PanFactor;
                else
                    bound=bound-width*PanFactor;
                end
                db.Axes.YLim=bound;
            case 'space'
                if hTabGroup.SelectedTab == hTab(2)
                    storeData();
                end
        end
    end

figure(db.Figure);

end