% loadSMASH Make toolbox available to MATLAB
%
% This function makes the SMASH toolbox available to MATLAB.  Typing:
%    >> loadSMASH % initial setup
% places the toolbox's root directory on the path and creates a startup
% file for future sessions; it also enforces that root directory be named
% 'SMASHtoolbox'.  If a starup file already exists, those commands are
% stored as comments after the automatically generated code.  This is the
% recommended approach for most SMASH users.  
%
% DO *NOT* USE "Add with subfolders" feature of MATLAB's Set Path tool for
% this toolbox!!!
%
% Toolbox programs may be added to the MATLAB path after initial setup.
%      loadSMASH -program name % specific program or programs
% Once loaded, programs can be called by name from any workspace throughout
% the current MATLAB session.  Frequently used programs should be loaded
% by placing commands in the startup file.  For example:
%      loadSMASH -silent -program * 
%  allows all programs to be called from the command window.
%      >> SIRHEN  % launches SIRHEN program
% The "-silent" option suppresses the information printed to the command
% window.
%
% See also SMASHtoolbox, packtools
%
function varargout=loadSMASH(varargin)

% manage input
if nargin == 0
    setupToolbox();
    return
end

verbose=true;
mode='';
name={};
while numel(varargin)>0
    switch varargin{1}
        case '-verbose'
            verbose=true;
            varargin=varargin(2:end);
        case '-silent'
            verbose=false;
            varargin=varargin(2:end);
        case {'-program','-programs'}
            assert(isempty(mode),'ERROR: mode conflict detected');
            mode=varargin{1};
            varargin=varargin(2:end);
            while numel(varargin)>0
                if varargin{1}(1)=='='
                    break
                end
                name{end+1}=varargin{1}; %#ok<AGROW>
                varargin=varargin(2:end);
            end             
        case {'package'}
            error('ERROR: use packtools to load packages');
        otherwise
            error('ERROR: invalid input detected');
    end
end
assert(~isempty(mode),'ERROR: no mode specified');
assert(~isempty(name),'ERROR: no names specified');

% load named directories
switch mode
    case {'-program' '-programs'}
        loadProgram(name,verbose);
        if nargout > 0
            varargout{1}=name;
        end             
end

end
%%
function setupToolbox()

% look for startup file
commandwindow();
file=which('startup.m');
flag=false;
old={};
if isfile(file)
    fid=fopen(file,'r');
    while ~feof(fid)
        old{end+1}=fgets(fid); %#ok<AGROW> 
        if contains(old{end},'SMASH')
            flag=true;
        end
    end
    fclose(fid);    
end
if flag
    fprintf('SMASH toolbox may already be loaded\n');
    answer=input('Type "yes" to restore default setup: ','s');
    if ~strcmpi(answer,'yes')
        fprintf('No toolbox changes made\n');
        return
    end
end

% remove all references to SMASH from the path
list=path();
stop=strfind(list,pathsep)-1;
stop(end+1)=numel(list);
start=1;
for n=1:numel(stop)
    entry=list(start:stop(n));
    if contains(entry,'SMASH')
        rmpath(entry);
    end
    start=stop(n)+2;
end

% enforce directory name (this doesn't play nice with git)
start=pwd;
original=fileparts(mfilename('fullpath'));
if contains(start,original)
    cd('..');
end
[root,~]=fileparts(original);
location=fullfile(root,'SMASHtoolbox');
if strcmp(original,location)
    % name already correct
elseif ~isdir(fullfile(original, '.git'))
    fprintf('Configuring toolbox directory...')
    if strcmpi(original,location)
        backup=fullfile(tempdir(),'SMASHtoolbox');        
        copyfile(original,backup,'f');
        try
            rmdir(original,'s'); % this is what causes git issues
        catch
            warning('Failed to entirely remove old directory');
        end
        original=backup;
    end
    movefile(original,location,'f');
    fprintf('done\n');
else
    fprintf('Maintaining toolbox directory name to avoid git conflicts\n')
    location = original;
end

% create startup file
file=which('startup.m');
if isfile(file)
    fprintf('Overwriting startup file, storing previous commands as comments\n');   
else
    fprintf('Creating startup file\n');
    file=fullfile(userpath(),'startup.m');    
end
fid=fopen(file,'w');
fprintf(fid,'%% startup file created by loadSMASH %s\n',datestr(now));
fprintf(fid,'function startup()\n\n');
fprintf(fid,'addpath(''%s'');\n\n',location);
fprintf(fid,'end\n\n');
if ~isempty(old)
    fprintf(fid,'%% Previous startup file\n');
    for n=1:numel(old)
        fprintf(fid,'%% %s',old{n});
    end
end
fclose(fid);
startup();

end

%%
function loadProgram(name,verbose)

% look at program directory
local=mfilename('fullpath');
[local,~]=fileparts(local);
local=fullfile(local,'programs');
list=scanDirectory(local);

% load requested program(s)
if (numel(name)==1) && strcmp(name{1},'*')
    name=list;
end

N=numel(name);
for k=1:N
    test=cellfun(@(x) strcmp(x,name{k}),list);
    match=find(test,1);
    if isempty(match)       
        warning('SMASHtoolbox:program',...
            'Program %s not found in SMASH toolbox',name{k});
    elseif strcmpi(name{k},'development')
        continue % skip development directory
    else
        addpath(fullfile(local,name{k}));
        if verbose
            fprintf('Adding %s to the MATLAB path\n',name{k});
        end
    end
end

end

%% utility function
function list=scanDirectory(dirname,mode)

if (nargin<2) || isempty(mode)
    mode='standard';
end

list={};
filename=dir(dirname);
for k=1:numel(filename)
    if ~filename(k).isdir % non-directory
        continue
    elseif filename(k).name(1)=='.' % hidden directory
        continue
    elseif strcmp(mode,'standard') && (filename(k).name(1) ~='+') % package directory
        list{end+1}=filename(k).name; %#ok<AGROW>
    elseif strcmp(mode,'package')  && (filename(k).name(1) =='+') % standard directory
        list{end+1}=filename(k).name(2:end); %#ok<AGROW>
    end
end

end