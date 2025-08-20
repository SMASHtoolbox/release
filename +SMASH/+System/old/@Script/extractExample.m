% extractExample Extract examples from toolbox
%
% This method extracts MATLAB scripts(s) from the "examples" directory of
% the SMASH toolbox and copies them to a local subdirectory.
%    Script.extractExample(); % extract all scripts
%    Script.extractExample(subdir); % extract script from one subdirectory
% Examples are extracted as standard (*.m) or live (*.mlx) scripts based on
% how they were inserted.
%
% See also Script, insertExample
%

%
% created January 10, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=extractExample(name)

% manage input
if (nargin < 1) || isempty(name)
    name='*.m';
elseif strcmpi(name,'-all')
    name='*';
else
    assert(ischar(name),'ERROR: invalid example name');
    k=(name == '/') | (name == '\');
    name(k)=filesep;
end

% copy files
local=fullfile(pwd,'examples');
if ~exist(local,'dir')
    mkdir(local)
end

[subdir,name,ext]=fileparts(name);
name=[name ext];
source=fullfile(smashroot,'examples',subdir);
if exist(fullfile(source,name),'dir')
    list.name=name;
    list.isdir=true;
else
    list=dir(fullfile(source,name));
end

report=cell(numel(list),1);
for n=1:numel(list)
    if list(n).name(1)=='.'
        continue   
    end
    new=fullfile(local,subdir,list(n).name);
    [temp,~,~,]=fileparts(new);
    if ~exist(temp,'dir')
        mkdir(temp);
    end    
    [~,temp,~]=fileparts(list(n).name);
    fprintf('Copying "%s"',temp);
    temp=fullfile(source,list(n).name);
    copyfile(temp,new,'f');
    report{n}=new;
    if list(n).isdir
        sub=dir(fullfile(new,'*.m'));
        for k=1:numel(sub)
            temp=fullfile(new,sub(k).name);
            if isLive(temp)
                packtools.call('Script.convert',temp,'','-overwrite');                
            end            
        end
        junk=dir(fullfile(new,'.*'));
        for k=1:numel(junk)
            switch junk(k).name
                case {'.' '..'}
                    % do nothing
                otherwise
                    temp=fullfile(new,junk(k).name);
                    delete(temp);
            end
        end
    elseif isLive(temp)
        packtools.call('Script.convert',new,'','-overwrite');
        delete(new);
    end
    fprintf('\n');
end

% manage output
if nargout > 0
    varargout{1}=report;
end

end

function value=isLive(filename)

value=false;

[pname,fname,~]=fileparts(filename);
log=fullfile(pname,['.' fname]);
try
    fid=fopen(log,'r');
    temp=fgets(fid);
catch
    return
end
fclose(fid);

if strcmpi(strtrim(temp),'live')
    value=true;
end

end