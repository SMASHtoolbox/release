function DisplayOptions(varargin)

% handle input
fig=varargin{3};
updatefunc=varargin{4};

% access data
data=get(fig,'UserData');

% prompt user
label{1}='Color scaling:';
label{2}='Scale range (min max):';
label{3}='Color map:';
label{4}='Invert map:';
options.root=fig;
options.location='center';
default={data.scaling, sprintf('%g ',data.clim), data.map, data.invertmap};
answer=datadlg_display('Display parameters',label,default,options);
if isempty(answer)
    return
end

scaling=sscanf(answer{1},'%s',1);
clim=sort(sscanf(answer{2},'%g',2));
map=sscanf(answer{3},'%s',1);
if islogical(answer{4})
    if answer{4}
        invertmap='yes';
    else
        invertmap='no';
    end
else    
invertmap=sscanf(answer{4},'%s',1);
end
if isempty(scaling) || (numel(clim)<2) || isempty(map) || isempty(invertmap)
    DisplayOptions([],[],varargin{:});
    return
end

% look for changes
% change=~strcmp(data.scaling,scaling)| any(data.clim(:)~=clim(:))...
%     | ~strcmp(data.map,map) | ~strcmp(data.invertmap,invertmap); 
% if change
same=strcmp(data.scaling,scaling) & all(data.clim(:)==clim(:))...
     & strcmp(data.map,map) & strcmp(data.invertmap,invertmap);
if ~same
    data.scaling=scaling;
    data.clim=clim;
    data.map=map;
    data.invertmap=invertmap;
    set(fig,'UserData',data);
    feval(updatefunc,fig);
end