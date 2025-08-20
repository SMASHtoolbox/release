% deploy Collect MATLAB code for deployment
%
% 
% 
function deploy(source,destination)

% manage input
if (nargin < 1) || isempty(source)
    source=pwd;
end
assert(logical(exist(source,'file')),'ERROR: invalid source');

if (nargin < 2) || isempty(destination)
    destination=fullfile(pwd,'deploy');
end

% analyze source(s) for dependencies
if exist(source,'dir') == 7
    temp=dir(source);
    source={};
    for m=1:numel(temp)
        name=temp(m).name;
        if name(1)=='.'
            continue % ignore hidden files
        elseif (name(end)=='~') || strcmpi(name(end-3:end),'.asv')
            continue % ignore backups
        elseif temp(m).isdir
            continue % ignore directories (dependent stuff managed separately)
        end
        source{end+1}=fullfile(temp(m).folder,temp(m).name); %#ok<AGROW>
    end    
end

fprintf('Analyzing dependencies...');
source=matlab.codetools.requiredFilesAndProducts(source);
fprintf('done\n');

pattern{1}=[filesep '+'];
pattern{2}=[filesep '@'];
pattern{3}=[filesep 'private' filesep];
fprintf('Copying files...');
for m=1:numel(source)
    start=inf;
    for n=1:numel(pattern)
        temp=strfind(source{m},pattern{n});
        if isempty(temp)
            continue
        else
            start=min(start,temp(1));
        end
    end
    if isinf(start)
        [~,name,ext]=fileparts(source{m});
        name=fullfile(destination,[name ext]);
    else
        name=fullfile(destination,source{m}(start+1:end));
    end
    new=fileparts(name);
    if ~exist(new,'dir')
        mkdir(new);
    end
    copyfile(source{m},name,'f');    
end
fprintf('done\n');

end