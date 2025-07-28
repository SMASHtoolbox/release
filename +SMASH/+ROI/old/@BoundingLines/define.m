% define Manually define bounding values
%
% This method manually defines bounding line positions.
%    >> object=define(object,[lower upper]);
%
% See also BoundingLines, select
%

%
% created November 14, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=define(object,data)

% handle input
assert(nargin>=2,'ERROR: insufficient input');
if isempty(data)
    data=[-inf +inf];
end
assert(numel(data)==2,'ERROR: invalid data');

data=sort(data);
object.Data=reshape(data,[1 2]);
   
end