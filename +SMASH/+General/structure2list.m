% structure2list Convert a structure to a name/value list
%
% This function converts a MATLAB structure to a cell array of name/value
% pairs.
%    list=structure2list(data);
%
% See also SMASH.General
%

%
% created March 3, 2016 by Daniel Dolan  (Sandia National Laboratories)
%
function list=structure2list(data)

% manage input
assert(isscalar(data),'ERROR: structure arrays are not supported');

% perform conversion
name=fieldnames(data);
N=numel(name);
list=cell(1,2*N);
for n=1:N
    list{2*n-1}=name{n};
    list{2*n}=data.(name{n});
end

end