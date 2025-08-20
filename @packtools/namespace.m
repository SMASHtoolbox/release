% namespace Generate pacakge name space
%
% This method generates a name space for package functions and classes.
% The standard calling syntax is:
%    ns=packtools.namespace(request);
% where "request" is the requested package contents.  The output "ns" is a
% structure of function handles.
%
% Requests typically use wildcards to specify some or all of the package
% contents.  For example:
%    ns=packtools.namespace('MainPackage.SubPackage.*');
% returns handles to all functions and classes from
% "MainPackage.SubPackage".  Specific names and name patterns can also be
% requested.
%    ns=packtools.namespace('MainPackage.SubPackage.MyFunction'); % specific name
%    ns=packtools.namespace('MainPackage.SubPackage.My*'); % name pattern
% The function "MyFunction" can be called as:
%    [...]=ns.MyFunction(...);
% where dots indicate the function inputs and outputs.  
% NOTE: function calls with no inputs should still use parenthesis.
%    [...]=ns.MyFunction(); % no function inputs
% MATLAB does not require parenthesis in standard function calls, but it is
% necessary here to invoke function evaluation.
%
% Name spaces created with a package can use local naming instead of
% absolute name.
%    ns=packtools.namespace('local',request);
% For example, a function in "MainPackage.SubPackage" could use local
% naming to access local functions without knowing their absolute package
% location.
%    ns=packtools.namespace('local','*');
%    [...]=ns.MyFunction(...);
%
% See also packtools, call
%

%
% created May 17, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function result=namespace(varargin)

warning('This method is being phased out.  Use the "import" method instead');

% manage input
switch nargin
    case 0
        error('ERROR: insufficient input');
    case 1
        mode='absolute';
        request=varargin{1};
    case 2
        assert(strcmpi(varargin{1},'local'),'ERROR: invalid input');
        mode='local';
        request=varargin{2};
    otherwise
        error('ERROR: too many inputs');
end

% find package
if strcmp(mode,'local')
    [st,index]=dbstack('-completenames');
    errmsg='ERROR: this method must be called from inside a package';
    assert(numel(st) > 1,errmsg);
    if index ~= 1
        st=st(end:-1:1);
    end
    package=file2package(st(2).file);
    object=meta.package.fromName(package);
    while true
        index=strfind(request,'.');
        if isempty(index)
            request=sprintf('%s.%s',object.Name,request);
            break
        elseif request(1)=='-'
            object=meta.package.fromName(object.ContainingPackage.Name);
            request=request(3:end);                  
        end
    end
end

errmsg='ERROR: invalid package request';
index=strfind(request,'.');
assert(~isempty(index),errmsg);
package=request(1:index(end)-1);
request=request(index(end)+1:end);

try
    object=meta.package.fromName(package);
catch
    error(errmsg);
end

% find functions and classes in the package
result=struct();
expression=regexptranslate('wildcard',request);
for n=1:numel(object.ClassList)
    temp=object.ClassList(n).Name;
    if isempty(regexp(temp,expression, 'once'))
        continue
    end
    field=temp;
    target=sprintf('%s.%s',package,temp);
    result.(field)=str2func(target);   
end

for n=1:numel(object.FunctionList)
    temp=object.FunctionList(n).Name;
    if isempty(regexp(temp,expression, 'once'))
        continue
    end
    field=temp;
    target=sprintf('%s.%s',package,temp);
    result.(field)=str2func(target);
end

end