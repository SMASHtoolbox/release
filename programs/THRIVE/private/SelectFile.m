% select file callback (read from and write to target edit box)
function SelectFile(src,eventdata,target,RWoption,FilterSpec,DialogTitle)

% input check
if (nargin<4) || isempty(RWoption)
    RWoption='read';
end
if (nargin<5) || isempty(FilterSpec)
    FilterSpec={'*.*','All files'};
end
if (nargin<6) || isempty(DialogTitle)
    DialogTitle='Select file name';
end

data=get(src,'UserData');
if isfield(data,'start')
    start=data.start;
else
    start=pwd;
end

switch RWoption
    case 'read'
        [name,pathname]=uigetfile(FilterSpec,DialogTitle,start);
    case 'write'
        [name,pathname]=uiputfile(FilterSpec,DialogTitle,start);
end

if isnumeric(name) % user pressed cancel
    return
end
name=fullfile(pathname,name);
set(target,'String',name);

% save pathname to start future selections
data.start=pathname;

figA=findobj(0,'Type','figure','Tag','THRIVE_LoadScreen');
h(1)=findobj(figA,'Tag','File1Select');
h(2)=findobj(figA,'Tag','File1Select');
h(3)=findobj(figA,'Tag','File1Select');

figD=findobj(0,'Type','figure','Tag','THRIVE_ResultsScreen');
h(4)=findobj(figD,'Tag','ExportFileSelect');

set(h,'UserData',data);