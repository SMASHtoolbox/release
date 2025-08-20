function list=scanDirectory(target,match,hidden)

% manage input
if (nargin<1) || isempty(target)
    target=pwd;
end

if (nargin<2) || isempty(match)
    match='*';
end
assert(ischar(match),'ERROR: invalid match string');

if (nargin<3) || isempty(hidden)
    hidden=true;
end

list={};

% start with directories
file=dir(target);
for n=1:numel(file)
    if ~file(n).isdir
        continue
    elseif strcmp(file(n).name,'.') || strcmp(file(n).name,'..')
        continue
    elseif (file(n).name(1)=='.') && ~hidden
        continue
    end
    list{end+1}=[file(n).name filesep]; %#ok<AGROW>
end

% look for additional matches
while ~isempty(match)
    k1=strfind(match,';');
    if isempty(k1)
        k1=numel(match);
    end
    [~,~,~,k2]=sscanf(match,'%s',1);   
    k=min(k1,k2-1);
    file=dir(fullfile(target,strtrim(match(1:k))));
    for n=1:numel(file)
        if file(n).isdir
            continue
        elseif (file(n).name(1)=='.') && ~hidden
            continue
        end
        list{end+1}=file(n).name; %#ok<AGROW>
    end
    match=match(k+1:end);    
end

end