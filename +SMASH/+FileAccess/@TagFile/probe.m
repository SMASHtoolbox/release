% probe Probe tagged file
%
% This method looks for tagged blocks within a text file.
%    list=probe(object); % return list of tags
%    probe(object); % prints list in the command window
%
% Repeated tags found in the same file will generate warnings.
%
% See also TagFile, read, write
%

%
% created October 16, 2018 by Daniel Dolan (Sandia National Laboratories)
%

function varargout=probe(object)

file=fullfile(object.PathName,object.FileName);
fid=fopen(file,'r');
CU=onCleanup(@() fclose(fid));

tag={};
start=[];
k=0;
while ~feof(fid)   
    temp=strtrim(fgetl(fid));
    k=k+1;
    if isempty(temp) || temp(1) ~= '['
        continue
    end
    right=find(temp == ']',1,'first');
    if isempty(right)
        continue
    end
    new=temp(2:right-1);
    temp=strtrim(temp(right+1:end));
    if isempty(temp)
        tag{end+1}=new; %#ok<AGROW>
        start(end+1)=k; %#ok<AGROW>
    end        
end
stop=start(2:end)-1;
stop(end+1)=k;

% look for duplication
keep=true(size(tag));
for m=1:numel(tag)
    for n=(m+1):numel(tag)
        if strcmpi(tag{m},tag{n})
            keep(n)=false;            
        end
    end    
end

if ~all(keep)
    temp=unique(tag(~keep));
    message=cell(numel(temp)+1,1);
    message{1}='File contains repeated tags:';
    for n=1:numel(temp)
        message{n+1}=sprintf('   %s',temp{n});
    end
    if isscalar(temp)
        message{end+1}='Referencing this tag returns the first block only';
    else      
        message{end+1}='Referencing these tags returns the first block only';
    end
    warning('%s\n',message{:});

    tag=tag(keep);
    start=start(keep);
    stop=stop(keep);
end

% look for invalid tags
keep=true(size(tag));
message={'File contains invalid tags:'};
for m=1:numel(tag)
    if any(tag{m} == '[') || any(tag{m} == ']') || (tag{m}(1) == '-')
        keep(m)=false;
        message{end+1}=sprintf('   %s',tag{m}); %#ok<AGROW>
    end
end

if ~all(keep)
    message{end+1}='These blocks cannot be referenced';
    warning('%s\n',message{:});
    tag=tag(keep);
    start=start(keep);
    stop=stop(keep);
end

% manage output
if nargout == 0  
    if isscalar(tag)
        fprintf('File contains 1 tag block\n');
    else
        fprintf('File contains %d tag blocks\n',numel(tag));
    end
    fprintf('   %s\n',tag{:});
else
    varargout{1}=tag;
    varargout{2}=start;
    varargout{3}=stop;
end

end