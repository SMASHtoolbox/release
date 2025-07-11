% call Relative package call
%
% This method allows relative package calls, allowing functions/classes in
% a package hierarchy to reference one another without explicit package
% naming.
%    [...]=packtools.call(name,...); % dots indicate named function inputs and outputs
% The input "name" can reference items from the current package directory
% or package directories above/below this level.  Super-packages are
% indicated by a minus sign while sub-packages are specified by name
%
% The following examples use the hiearchy from the packtools documentation.
%    - "MainFuncA" references "MainFuncB" by name='MainFuncB'.
%    - "SubFuncA" references "SubFuncB" by name='SubFuncB'.
%    - "MainFuncA" references "SubFuncA" by name='SubPackage1.SubFuncA'.
%    - "SubFuncA" references "MainFuncB" by name='-.MainFuncB'.
%    - "SubFuncA" references "SubFuncC" by name='-.SubPackage2.SubFuncC'.
% References within a package may begin with an optional dot: name='.func'
% is equivalent to name='func'.
%
% NOTE : repeated calls to the same function with this method will be
% slower than importing that function to a variable.
%
% See also packtools, import, search
%

%
% created May 14, 2017 by Daniel Dolan
%
function varargout=call(name,varargin)

% test how method was called
[st,index]=dbstack('-completenames');
errmsg='ERROR: this method must be called from inside a package';
assert(numel(st) > 1,errmsg);
if index ~= 1
    st=st(end:-1:1);
end

package=file2package(st(2).file);
name=resolveName(package,name);

% manage output
if nargout > 0
    varargout=cell(1,nargout);
    [varargout{:}]=feval(name,varargin{:});
else
    feval(name,varargin{:});
end


end