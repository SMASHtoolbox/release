%

%%
function varargout=ZDAS(varargin)

%% handle input
assert((nargin>0),'ERROR: invalid number of inputs');

if ischar(varargin{1})
    local=varargin{1};
    assert(exist(local,'dir'),'ERROR: invalid local directory');    
    network='';
    if (nargin==2) && ischar(varargin{2})
        network=varargin{2};      
        assert(exist(network,'dir'),'ERROR: invalid network directory');
    end
    location=struct('local',local,'network',network);
    setappdata(0,'ZDAS',location);
    return
elseif isnumeric(varargin{1}) && round(varargin{1})==varargin{1}
    shot=round(varargin{1});    
else
    error('ERROR: invalid shot number');    
end

if (nargin<2) || isempty(varargin{2})
    source='cmdas';
else
    source=varargin{2};
end
switch lower(source)
    case {'c','cmdas'}
        source='c';
    case {'t','tcwagon'}
        source='t';
    case {'j','jkmoore'}
        source='j';
    case {'s','saturn'}
        source='s';
    otherwise
        error('ERROR: invalid source name');
end    


if (nargin<3) 
    label={};
else
    label=varargin{3};
end
if ischar(label)
    label={label};
elseif iscell(label) && all(cellfun(@ischar,label))
    % do nothing
else
    error('ERROR: invalid label input');
end

%% look for file
if isappdata(0,'ZDAS')
    location=getappdata(0,'ZDAS'); 
else
    error('ERROR: ZDAS location is undefined');
end


%% handle output


end

%% file name generator
function name=generate_name(shot,location,source)

% locate file
switch source
    case 'c'
        filename=sprintf('pbfa2z_%d.hdf',shot);
        name=fullfile(location.local,filename);
        if exist(name,'file')
           return 
        end
        name=fullfile(location.network,filename);
        if exist(name,'file')
            return
        end        
    case 't'
        filename=sprintf('pbfa2z_%d_tcwagon.hdf',shot);
        name=fullfile(location.local,'Z',filename);
        if exist(name,'file')
           return 
        end
        name=fullfile(location.network,'scratch',filename);
        if exist(name,'file')
            return
        end               
    case 'j'
        filename=sprintf('pbfa2z_%d_jkmoore.hdf',shot);
        name=fullfile(location.local,'Z',signalfilename);
        if exist(name,'file')
           return 
        end
    case 's'
        filename=sprintf('Saturn_0%d.hdf',shot);
        name=fullfile(location.local,'Saturn_data','signal_data',filename);
        if exist(name,'file')
            return
        end             
end
error('ERROR: unable to locate ZDAS file');

end