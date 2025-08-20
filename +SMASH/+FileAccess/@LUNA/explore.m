% explore Explore scan
%
% This method provides interactive exploration of a LUNA scan
%    explore(object);
%
% See also LUNA
%

%
% created March 9, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=explore(object)

assert(exist('xline','file') == 2,...
    'ERROR: this method requires MATLAB 2018b or later');

c0=SMASH.Reference.PhysicalConstant('c0','SI');

%%
db=SMASH.MUI.DialogPlot('FontSize',14);
db.Hidden=true;
db.Name='OBR scan';
db.Hidden=true;
EditWidth=15;
ButtonWidth=18;
set(db.Figure,'Visible','off');

toolbar=findobj(db.Figure,'Type','uitoolbar');
hc=get(toolbar,'Children');
for n=1:numel(hc)
    tag=get(hc(n),'Tag');
    if contains(tag,'pan') || contains(tag,'zoom') ...
            || contains(tag,'saveas') || contains(tag,'directory')
        % keep
    else    
        delete(hc(n));
    end
end
%% menus
hm=uimenu(db.Figure,'Label','File');
uimenu(hm,'Label','Archive','Callback',@archiveScan);
    function archiveScan(varargin)
        [name,location]=uiputfile({'*.sda;*.SDA' 'Sandia Data Archives (*.sda)'},...
            'Select archive file');
        if isnumeric(name)
            return
        end
        name=fullfile(location,name);
        if exist(name,'file')
            delete(name)
        end
        archive=SMASH.FileAccess.SDAfile(name);
        insert(archive,'OBR',object,'LUNA OBR scan',2);
    end

hm=uimenu(db.Figure,'Label','Modify');
hsub=uimenu(hm,'Label','Change time step to');
uimenu(hsub,'Label','0.01 ns','Callback',@changeTimeStep);
uimenu(hsub,'Label','0.05 ns','Callback',@changeTimeStep);
uimenu(hsub,'Label','0.10 ns','Callback',@changeTimeStep);
uimenu(hsub,'Label','0.50 ns','Callback',@changeTimeStep);
uimenu(hsub,'Label','1.00 ns','Callback',@changeTimeStep);
    function changeTimeStep(varargin)
        step=sscanf(get(varargin{1},'Label'),'%g');
        current=modify(object,step);
        setRange();
        legend(hScan,[object.SourceFile ' (modified)'],...
            'Interpreter','none','AutoUpdate','off');
    end
hsub=uimenu(hm,'Label','Crop scan to ');
uimenu(hsub,'Label','Plot range','Callback',@changeRange);
uimenu(hsub,'Label','Onscreen range','Callback',@changeRange);
    function changeRange(varargin)
        switch get(varargin{1},'Label')
            case 'Plot range'
                xb=sscanf(get(hRange(2),'String'),'%g');
            case 'Onscreen range'
                xb=xlim(db.Axes(1));
        end
        object=modify(object,[],xb);
        current=modify(current,[],xb);
        legend(hScan,[object.SourceFile ' (modified)'],...
            'Interpreter','none','AutoUpdate','off');        
    end

%% controls 
hLeftTable=addblock(db,'table',{'Distance' 'A'},...
    [nan 8],3);
set(hLeftTable(1),'String','Cursor A:','ForeGroundColor','r',...
    'FontWeight','bold');
set(hLeftTable(2),'String','');
data=cell(3,2);
data{1,1}='RT time (ns)';
data{2,1}='Distance (m)';
data{3,1}='Ret. loss (dB)';
set(hLeftTable(end),'Data',data,'ColumnEditable',[false true true],...
    'CellEditCallback',@editLeftTable);
    function editLeftTable(varargin)
        data=get(hLeftTable(end),'Data');
        row=varargin{2}.Indices(1);
        switch row
            case 1
                t=sscanf(varargin{2}.NewData,'%g',1);
                if isempty(t)
                   data{row,2}=varargin{2}.PreviousData;
                   set(hLeftTable(end),'Data',data)
                else
                    set(hLeft{2},'Value',t);
                    updateLeftCursorTable();
                end                 
            case 2
                x=sscanf(varargin{2}.NewData,'%g',1);
                if isempty(x)
                    data{row,2}=varargin{2}.PreviousData;
                    set(hLeftTable(end),'Data',data)
                else
                    t=2e9*x/c0*object.GroupIndex;
                    set(hLeft{2},'Value',t);
                    updateLeftCursorTable();
                end
            case 3                
                data{row,2}=varargin{2}.PreviousData;             
                set(hLeftTable(end),'Data',data)
        end               
    end

hRightTable=addblock(db,'table',{'Distance' 'B'},...
    [nan 8],3);
set(hRightTable(1),'String','Cursor B:','ForeGroundColor','b',...
    'FontWeight','bold');
set(hRightTable(2),'String','');
data=cell(3,2);
data{1,1}='RT time (ns)';
data{2,1}='Distance (m)';
data{3,1}='Ret. loss (dB)';
set(hRightTable(end),'Data',data,'ColumnEditable',[false true true],...
    'CellEditCallback',@editRightTable);
    function editRightTable(varargin)
        data=get(hRightTable(end),'Data');
        row=varargin{2}.Indices(1);
        switch row
            case 1
                t=sscanf(varargin{2}.NewData,'%g',1);
                if isempty(t)
                   data{row,2}=varargin{2}.PreviousData;
                else
                    set(hLeft{2},'Value',t);
                    updateRightCursorTable();
                end                 
            case 2
                x=sscanf(varargin{2}.NewData,'%g',1);
                if isempty(x)
                    data{row,2}=varargin{2}.PreviousData;
                else
                    t=2e9*x/c0*object.GroupIndex;
                    set(hLeft{2},'Value',t);
                    updateRightCursorTable();
                end
            case 3                
                data{row,2}=varargin{2}.PreviousData;             
        end       
        set(hRightTable(end),'Data',data)
    end

hDifferenceTable=addblock(db,'table',{'Distance' ' '},[nan 8],2);
set(hDifferenceTable(1),'String','Difference:','FontWeight','bold');
data=cell(2,2);
data{1,1}='RT time (ns)';
data{2,1}='Distance (m)';
set(hDifferenceTable(end),'Data',data,'ColumnEditable',false);

hOptimize=addblock(db,'button','Optimize cursors',ButtonWidth);
set(hOptimize,'Callback',@optimizeCursors)
    function optimizeCursors(varargin)
        x=get(hLeft{1},'XData');
        y=get(hLeft{1},'YData');
        [~,index]=max(y);
        set(hLeft{2},'Value',x(index));
        updateLeftCursorTable();
        x=get(hRight{1},'XData');
        y=get(hRight{1},'YData');
        [~,index]=max(y);
        set(hRight{2},'Value',x(index));
        updateRightCursorTable();        
    end

hReset=addblock(db,'button','Reset cursors',ButtonWidth);
set(hReset,'Callback',@resetCursors);
    function resetCursors(varargin)
        xb=xlim(db.Axes(1));
        xs=get(hScan,'XData');
        xb(1)=max(xb(1),xs(1));
        xb(2)=min(xb(2),xs(end));
        x=get(hLeft{2},'Value');
        if (x < xb(1)) || (x > xb(2))
            x=xb(1)+0.10*(xb(2)-xb(1));
            set(hLeft{2},'Value',x);
            updateLeftCursorTable();
        end
         x=get(hRight{2},'Value');
        if (x < xb(1)) || (x > xb(2))
            x=xb(1)+0.90*(xb(2)-xb(1));
            set(hRight{2},'Value',x);
            updateRightCursorTable();
        end
    end

width=1; % ns
hWidth=addblock(db,'edit','Integration width (ns):',EditWidth);
set(hWidth(1),'FontWeight','bold');
temp=sprintf('%g',width);
set(hWidth(2),'String',temp,'UserData',temp,'Callback',@setWidth);
    function setWidth(varargin)
        new=sscanf(get(hWidth(2),'String'),'%g',1);
        if numel(new) == 1
            temp=sprintf('%g',new);
            set(hWidth(2),'String',temp,'UserData',temp);
            updateLeftCursorTable();
            updateRightCursorTable();
        else            
            set(hWidth(2),'String',get(hWidth(2),'UserData'));            
        end
    end

hRange=addblock(db,'edit','Plot range (ns):',EditWidth);
set(hRange(1),'FontWeight','bold');
temp='-inf +inf';
set(hRange(2),'String',temp,'UserData',temp,...
    'Callback',@setRange);
    function setRange(varargin)
        bound=get(hRange(2),'String');
        bound=sscanf(bound,'%g %g');
        if numel(bound) == 2
            keep=(current.Time >= bound(1)) & (current.Time <= bound(2));
            set(hScan,...
                'XData',current.Time(keep),'YData',current.LinearAmplitude(keep));
            bound=sprintf('%+g %+g',bound);
            % keep cursors inside range
            xb=current.Time(keep);
            xb=xb([1 end]);
            x=get(hLeft{2},'Value');            
            if (x < xb(1)) || (x > xb(2))
                x=xb(1)+0.10*(xb(2)-xb(1));
                set(hLeft{2},'Value',x);
                updateLeftCursorTable();
            end
            x=get(hRight{2},'Value');                      
            if (x < xb(1)) || (x > xb(2))
                x=xb(1)+0.90*(xb(2)-xb(1));
                set(hRight{2},'Value',x);
                updateRightCursorTable();
            end
            
        else
            bound=get(hRange(2),'UserData');
        end
        set(hRange(2),'String',bound,'UserData',bound);        
    end

%% lines
current=object;
hScan=line('Parent',db.Axes(1),'Color','k',...
    'XData',current.Time,'YData',current.LinearAmplitude);
xlabel(db.Axes(1),'Round trip time (ns)');
ylabel(db.Axes(1),'Linear return (1/mm)');
set(db.Axes(1),'YScale','log');
if object.IsModified
    label=sprintf('%s (modified)',current.SourceFile);
else
    label=sprintf('%s',current.SourceFile);
end
legend(hScan,label,'Interpreter','none','AutoUpdate','off');

%
left=object.Time(1);
right=object.Time(end);
L=0.10*(right-left);
left=left+L;
right=right-L;

hLeft{1}=line(db.Axes(1),nan,nan,'Color','r','Tag','LeftMarker',...
    'HandleVisibility','off');
hLeft{2}=xline(left,'Parent',db.Axes(1),'Color','r',...
    'Tag','LeftRegion','ButtonDownFcn',@moveLeftCursor,...
    'HandleVisibility','off');
    function moveLeftCursor(varargin)
        %dcm.Enable='off';
        OldMove=get(db.Figure,'WindowButtonMotionFcn');
        OldRelease=get(db.Figure,'WindowButtonUpFcn');
        set(db.Figure,'WindowButtonMotionFcn',@move,'WindowButtonUpFcn',@release);
        x=[];
        function move(varargin)
            x=get(db.Axes(1),'CurrentPoint');                       
            set(hLeft{2},'Value',x(1));                       
        end
        function release(varargin)
            set(db.Figure,'WindowButtonMotionFcn',OldMove,'WindowButtonUpFcn',OldRelease);
            updateLeftCursorTable()
            %dcm.Enable='on';
        end
    end
    function updateLeftCursorTable()
        data=get(hLeftTable(end),'Data');        
        t=get(hLeft{2},'Value');
        data{1,2}=sprintf('%.2f',t);
        data{2,2}=sprintf('%.3f',time2distance(t));        
        width=sscanf(get(hWidth(2),'String'),'%g');
        left=t-width/2;
        right=t+width/2;
        keep=(object.Time >= left) & (object.Time <= right);
        set(hLeft{1},'XData',object.Time(keep),'YData',object.LinearAmplitude(keep));
        x=object.Time;
        y=object.LinearAmplitude;
        area=trapz(x(keep),y(keep));
        RL=-10*log10(area);       
        data{3,2}=sprintf('%.1f',RL);
        set(hLeftTable(end),'Data',data);
        calculateDifferences();
    end

hRight{1}=line(db.Axes(1),nan,nan,'Color','b','Tag','RightMarker',...
    'HandleVisibility','off');
hRight{2}=xline(right,'Parent',db.Axes(1),'Color','b',...
    'Tag','RightRegion','ButtonDownFcn',@moveRightCursor,...
    'HandleVisibility','off');
function moveRightCursor(varargin)
        OldMove=get(db.Figure,'WindowButtonMotionFcn');
        OldRelease=get(db.Figure,'WindowButtonUpFcn');
        set(db.Figure,'WindowButtonMotionFcn',@move,'WindowButtonUpFcn',@release);
        x=[];
        function move(varargin)
            x=get(db.Axes(1),'CurrentPoint');                       
            set(hRight{2},'Value',x(1));                       
        end
        function release(varargin)
            set(db.Figure,'WindowButtonMotionFcn',OldMove,'WindowButtonUpFcn',OldRelease);
            updateRightCursorTable()
        end
    end
    function updateRightCursorTable()
        data=get(hRightTable(end),'Data');
        t=get(hRight{2},'Value');
        data{1,2}=sprintf('%.2f',t);
        data{2,2}=sprintf('%.3f',time2distance(t));
        width=sscanf(get(hWidth(2),'String'),'%g');
        left=t-width/2;
        right=t+width/2;
        keep=(object.Time >= left) & (object.Time <= right);
        set(hRight{1},'XData',object.Time(keep),'YData',object.LinearAmplitude(keep));
        x=object.Time;
        y=object.LinearAmplitude;
        area=trapz(x(keep),y(keep));
        RL=-10*log10(area);
        data{3,2}=sprintf('%.1f',RL);
        set(hRightTable(end),'Data',data);
        calculateDifferences();
    end

%
setRange();
updateLeftCursorTable();
updateRightCursorTable();
    function calculateDifferences()        
        data=get(hDifferenceTable(end),'Data');
        left=get(hLeft{2},'Value');
        right=get(hRight{2},'Value');
        t=abs(right-left);
        data{1,2}=sprintf('%+.2f',t);
        x=time2distance(t);
        data{2,2}=sprintf('%.3f',x);
        set(hDifferenceTable(end),'Data',data);       
    end


%%
set(db.Axes(1),'Box','off');
DistanceAxes=axes(db.PlotPanel,...
    'XAxisLocation','top','YAxisLocation','right',...
    'YScale','log');
hc=get(db.PlotPanel,'Children');
set(db.PlotPanel,'Children',hc(end:-1:1));
set(db.Axes(1),'Color','none');
xlabel(db.Axes(2),'Distance (m)');

AL=listener(db.Axes(1),{'XLim' 'XLimMode' 'YLim' 'YLimMode'},'PostSet',@updateDistance);
set(DistanceAxes,'UserData',AL);
    function updateDistance(varargin)                
        bound=get(db.Axes(1),'XLim');
        bound=time2distance(bound);
        set(db.Axes(2),'XLim',bound,'XTickMode','auto');
        %
        bound=get(db.Axes(1),'YLim');
        tick=get(db.Axes(1),'YTick');
        set(db.Axes(2),'YLim',bound,'YTick',tick,'YTickLabel',{});
        %
        pos=get(db.Axes(1),'Position');
        set(db.Axes(2),'Position',pos);
    end

%%
dcm=datacursormode(db.Figure);
dcm.Interpreter='none';
dcm.Enable='off';
dcm.UpdateFcn=@generateCursorText;

    function out=generateCursorText(~,info)
        t=info.Position(1);
        x=time2distance(t);
        out{1}=sprintf('RT time : %.2f ns',t);
        out{2}=sprintf('Distance: %.3f m',x);
    end

%%
    function x=time2distance(t)
        x=t/2e9; % convert round trip (ns) to single transit (s)
        x=x*c0/object.GroupIndex;
    end

%% finish up
set(db.Figure,'Units','normalized','Position',[0.10 0.10 0.80 0.80]);
set(db.Figure,'Resize','on');
finish(db);
set(db.Figure,'Visible','on');
updateDistance();

%% manage output
if nargout > 0
    varargout{1}=db.Figure;
end

end


