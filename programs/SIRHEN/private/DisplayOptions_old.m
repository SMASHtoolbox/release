function DisplayOptions(varargin)

% handle input
fig=varargin{3};
updatefunc=varargin{4};

% access data
data=get(fig,'UserData');

% prompt user
label{1}='Color scaling ([linear] or log) :';
label{2}='Scale range (min max, [0 1]):';
label{3}='Color map ([jet], gray, inverse_gray)';
default={data.scaling, sprintf('%g ',data.clim), data.map};
answer=datadlg('Display parameters',label,default);
if isempty(answer)
    return
end

scaling=sscanf(answer{1},'%s',1);
clim=sort(sscanf(answer{2},'%g',2));
map=sscanf(answer{3},'%s',1);
if isempty(scaling) || (numel(clim)<2) || isempty(map)
    DisplayOptions([],[],varargin{:});
    return
end

% look for changes
change=~strcmp(data.scaling,scaling)| any(data.clim(:)~=clim(:))...
    | ~strcmp(data.map,map);
if change
    data.scaling=scaling;
    data.clim=clim;
    data.map=map;
    set(fig,'UserData',data);
    feval(updatefunc,fig);
end