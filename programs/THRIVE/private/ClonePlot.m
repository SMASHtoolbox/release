function ClonePlot(src,varargin)

% get handles
parent=get(src,'Parent');
haxes=findall(parent,'Type','axes');

% separate legend objects
N=numel(haxes);
flag=false([1 N]);
for ii=1:N
    tag=get(haxes(ii),'Tag');
    if strcmp(tag,'legend')
        flag(ii)=true;
    end
end
hlegend=haxes(flag);
haxes=haxes(~flag);

% create figure
%fig=MinimalFigure('Visible','off');
fig=figure('Visible','off');
movegui(fig,'center');

% copy non-legend axes objects
new=copyobj(haxes,fig);

% recreate legends
for ii=1:numel(hlegend)  
    data=get(hlegend(ii),'UserData');      
    source=data.PlotHandle;  
    children=get(data.PlotHandle,'Children');
    handles=data.handles;
    Nhandle=numel(handles);
    match=ones([1 Nhandle]);
    for jj=1:Nhandle
        match(jj)=find(handles(jj)==children,1);
    end    
    kk=find(source==haxes);
    destination=new(kk);
    children=get(destination,'Children');        
    clean_legend(children(match),data.lstrings,'Location','Best'); % create new legend
    clean_legend(data.handles,data.lstrings,'Location','Best'); % refresh existing legend
end

% make figure visible
name=sprintf('Cloned plot (%s)',datestr(now));
set(fig,'NumberTitle','off','Name',name,'Visible','on');
refresh(ancestor(parent,'figure'));