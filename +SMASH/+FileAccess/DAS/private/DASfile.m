function target=DASfile(shot,style)

% check locations
assert(isappdata(0,'DASlocation'),'ERROR: no DAS locations found')
DASlocation=getappdata(0,'DASlocation');

% handle input
assert(isnumeric(shot),'ERROR: invalid shot number')
shot=int2str(shot);
style=lower(style);

% generate file name based on style
switch style
    case {'c','cmdas'}
        filename=sprintf('pbfa2z_%s.hdf',shot);
    case {'t','tcwagon'}
        filename=sprintf('z%s_tcwagon.hdf',shot);
    case {'j','jkmoore'}
        filename=sprintf('z%s_jkmoore.hdf',shot);
    case {'s','saturn'}
        filename=sprintf('Saturn_0%s.hdf',shot);
    otherwise
        error('ERROR: invalid style requested');
end

% look for local, then network target
target=fullfile(DASlocation.Local,filename);

if ~exist(target,'file')
    switch style
        case {'c','cmdas'}
            subdir='pbfa2z';
        case {'s','saturn'}
            error('ERROR: network access of SATURN files is not supported');
        otherwise
            subdir='scratch';
    end
    target=fullfile(DASlocation.Network,subdir,filename);
end

if ~exist(target,'file')
    switch style
        case {'t','tcwagon'}
            fprintf('Looking for jkmoore file (tcwagon file not found)\n');
            filename=sprintf('z%s_jkmoore.hdf',shot);
        case {'j','jkmoore'}
            fprintf('Looking for tcwagon file (jkmoore file not found)\n');
            filename=sprintf('z%s_tcwagon.hdf',shot);            
    end
    target=fullfile(DASlocation.Network,subdir,filename);
end
assert(exist(target,'file')==2,'ERROR: unable to locate file');

end