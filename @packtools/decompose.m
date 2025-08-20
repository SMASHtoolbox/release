% decompose Reduce call to package names
%
% This method decomposes an absolute call to a list of package names.
%    [package,name]=decompose(call);
% For example, the call 'Main.Sub.Function' is reduced to:
%    package={'Main'; 'Sub'];
%    name='Function';
%
% See also packtools
%

%
% created November 2 by Daniel Dolan (Sandia National Laboratories)
%
function [package,name]=decompose(in)

% manage input
assert((nargin == 1) && ischar(in),'ERROR: invalid package name');

index=strfind(in,'.');
if isempty(index)
    package={};
    name=in;
    return
end

%
N=numel(index);
package=cell(N,1);
start=[1 index(end-1)+1];
stop=[index(1) index(end)]-1;
for n=1:N
    package{n}=in(start(n):stop(n));
end

name=in(index(end)+1:end);

end