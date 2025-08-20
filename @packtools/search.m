% search Search package
%
% This method performs a case-insensitive name search for functions/classes
% inside a package.
%    result=pathtools.search(package,name);
% The input "package" is usually an absolute name.  The input "name"
% specifies the desired search pattern.  Wild cards can be used for complex
% searches:
%    result=pathtools.search(package,'analysis');  
%    result=pathtools.search(package,'signal*analysis'); 
% The first example looks for names containing 'analysis', while the second
% example looks for names containing both 'signal' and 'analysis', possibly
% intermediate characters.
%
% The output "result" is a cell array of strings listing the
% full package call to any matches found during the search.  If no output
% is requested, the results are printed in the command window.
%
% Package searches are automatically recursive, so the above examples will
% search 'Package' and any sub-packages contained within.  This behavior
% can be disabled with a third input
%    result=pathtools.search(package,name,'flat'); % search current directory only
%    result=pathtools.search(package,name,'recursive'); % recursive search (default)
%
% Relative package names are permitted when this method is called from a
% function or class method residing inside of a package.  Names beginning
% with a period indicate the current package; dashed indicate parent
% packages.
%    result=pathtools.search('.',name); % current package
%    result=pathtools.search('.sub',name); % sub-package of the current package
%    result=pathtools.search('-.',name); % parent package
%
% See also packtools, call, import
%

%
% created May 18, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=search(package,name,mode)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(ischar(package) && ischar(name),'ERROR: invalid input');

if strcmp(package(1),'.') || strcmp(package(1),'-')
    [st,index]=dbstack('-completenames');
    assert(numel(st) > 1,...
        'ERROR: this method must be called from inside a package');
    if index ~= 1
        st=st(end:-1:1);
    end
    source=file2package(st(2).file);
    while numel(package) > 0
        index=strfind(source,'.');
        if package(1) == '-'
            assert(numel(index) > 0,'ERROR: invalid name requested');
            stop=index(end);
            source=source(1:stop-1);
            package=package(2:end);
            continue
        elseif package(1) == '.'
            package=sprintf('%s.%s',source,package(2:end));
        else
            package=sprintf('%s.%s',source,package);
        end
        break
    end
end
if package(end)=='.'
    package=package(1:end-1);
end

try
    object=meta.package.fromName(package);
    assert(numel(object)==1);
catch
    error('ERROR: invalid package name');
end

if (nargin < 3) || isempty(mode)
    mode='recursive';
else
    assert(ischar(mode),'ERROR: invalid search mode');
end
mode=lower(mode);
switch mode
    case {'recursive' 'flat'}
        % valid choice
    otherwise
        error('ERROR: invalid search mode');
end

% perform search
expression=regexptranslate('wildcard',name);
result=dig(object,expression,mode);

% manage output
if nargout==0
    fprintf('%s\n',result{:});
else
    varargout{1}=result;
end

end

function match=dig(object,expression,mode)

match={};

for n=1:numel(object.ClassList)
    temp=object.ClassList(n).Name;
    if isempty(regexpi(temp,expression, 'once'))
        continue
    end
    match{end+1}=temp; %#ok<AGROW>
end

for n=1:numel(object.FunctionList)
    temp=object.FunctionList(n).Name;
    if isempty(regexpi(temp,expression, 'once'))
        continue
    end
    %match{end+1}=temp; %#ok<AGROW>
    match{end+1}=sprintf('%s.%s',object.Name,temp); %#ok<AGROW>
end

if strcmp(mode,'recursive')
    for n=1:numel(object.PackageList)
        temp=meta.package.fromName(object.PackageList(n).Name);
        temp=dig(temp,expression,mode);
        match=[match temp]; %#ok<AGROW>
    end
end

end
