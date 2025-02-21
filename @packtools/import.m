% import Import package
%
% This method imports package files and classes.
%    ns=packtools.import(name);
% The input "name" can be an absolute package name with or without wild
% cards.
%    ns=packtools.import('Main.Sub.Function');
%    ns=packtools.import('Main.Sub.*');
% Relative naming is permitted when this method is called from a package
% function/class.
%    ns=packtools.import('.Function'); % local package file
%    ns=packtools.import('.*'); % all local package files
%    ns=packtools.import('.Sub.*'); % all subpackage files
%    ns=packtools.import('-.*'); % all parent package files
% Multiple packages can be imported at the same time.
%    ns=packtools.import('PackageA.*','PackageB.Function');
%
% The output "ns" is structure of function handles, which can be used as a
% name space.  Imported features are called by name.
%    [...]=ns.Function(...); % dots indicate imported function inputs/outputs
% For maximum performance, imported name spaces should be stored in a
% persistent variable to minimize overhead during repeated function calls.
%
% See also packtools, call, search
%

%
% created May 18, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=import(varargin)

% manage input
if nargin==1
    name=varargin{1};
elseif (nargin > 1)
    result=struct();
    for m=1:nargin
        temp=packtools.import(varargin{m});
        field=fieldnames(temp);
        for n=1:numel(field)
            assert(~isfield(result,field{n}),'ERROR: name conflict detected');
            result.(field{n})=temp.(field{n});
        end
    end
    result=orderfields(result);
    exitStrategy();
    return
else
    error('ERROR: insufficient input');
end

assert(ischar(name) && ~isempty(name),'ERROR: invalid input');
errmsg='ERROR: invalid name requested';

% relative name
if strcmp(name(1),'.') || strcmp(name(1),'-')
    [st,index]=dbstack('-completenames');
    assert(numel(st) > 1,...
        'ERROR: this method must be called from inside a package');
    if index ~= 1
        st=st(end:-1:1);
    end
    package=file2package(st(2).file);
    while numel(name) > 0
        index=strfind(package,'.');
        if name(1) == '-'
            assert(numel(index) > 0,errmsg);
            stop=index(end);
            package=package(1:stop-1);
            name=name(3:end);       
            continue
        elseif name(1) == '.'
            name=sprintf('%s.%s',package,name(2:end));
        else            
            name=sprintf('%s.%s',package,name);
        end
        break
    end  
    result=packtools.import(name);
    exitStrategy();
    return
end   

% absolute name
index=strfind(name,'.');
assert(~isempty(index),errmsg);
package=name(1:index(end)-1);
name=name(index(end)+1:end);

try
    object=meta.package.fromName(package);
    assert(~isempty(object));
catch
    error(errmsg);
end

result=struct();
for n=1:numel(object.ClassList)
    temp=object.ClassList(n).Name;
    start=strfind(temp,'.');
    start=start(end)+1;
    ShortName=temp(start:end);
    if testName(ShortName,name)
        result.(ShortName)=str2func(temp);
    end    
end

for n=1:numel(object.FunctionList)
    temp=object.FunctionList(n).Name;
    if strcmpi(temp,'Contents')
        continue
    end
    if testName(temp,name)
        field=temp;
        target=sprintf('%s.%s',package,temp);
        result.(field)=str2func(target);
    end    
end

% manage output
if nargout == 0
    name=fieldnames(result);
    for n=1:numel(name)
        command=sprintf('exist(''%s'',''var'')',name{n});        
        value=evalin('caller',command);
        if value
            warning('packtools:import','Overwriting "%s" with package content',name{n});
        end
        assignin('caller',name{n},result.(name{n}));
    end
else
    exitStrategy();
end

    function exitStrategy()
        varargout{1}=result;
        varargout{2}=package;
    end

end

function result=testName(name,pattern)

% manage input
assert(nargin==2,'ERROR: invalid number of inputs');
assert(ischar(name) && ischar(pattern),'ERROR: invalid input(s)');

if any(name == '*')
    error('ERROR: name cannot contain wild cards');
end

name=reshape(name,[1 numel(name)]);
pattern=reshape(pattern,[1 numel(pattern)]);

% look for wildcards
wild=strfind(pattern,'*');
if isempty(wild)
    result=strcmp(name,pattern);
    return
end

change=diff(wild);
assert(all(change > 1),'ERROR: sequential wild cards are not permitted');

% work through the pattern
result=false;
while true
    if isempty(pattern)
        if isempty(name)
            result=true; % success
        end
        break
    elseif isempty(name)
        if strcmp(pattern,'*')
            result=true; % success
        end
        break
    elseif name(1) == pattern(1)
        name=name(2:end);
        pattern=pattern(2:end);
    elseif pattern(1) == '*'
        stop=find(pattern(2:end)=='*',1,'first');        
        if isempty(stop)
            remain=pattern(2:end);            
            pattern='';
        else
            remain=pattern(2:stop);
            pattern=pattern(stop+1:end);
        end
        if isempty(remain)
            name='';
            continue
        end
        M=numel(remain);
        start=strfind(name,remain);
        if start
            name=name(start+M:end);
        else
            break
        end
    else
        break
    end    
end

end