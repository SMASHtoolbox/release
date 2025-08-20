% define Manually define points
%
% This method manually defines rectangular bounds for a region interest.
%    object=define(object,bound);
% The input "bound" is a 2-4 element array, depending on the object's Mode
% property.  
%    -For 'xy' mode, the array defines [xb(1) xb(2) yb(1) y(b)]
%    -For 'x' mode, the array defines [xb(1) xb(2)];
%    -For 'y' mode, the array defines [yb(1) yb(2)];
% Bounds must be numerical values or NaN placeholders; the latter
% maintains the current boundary settings.  Infinite values indicate that
% the rectangle is unbounded along a particular direction, e.g.:
%    object=define(object,[0 inf 0 inf]);
% is a rectangle spanning the first quadrant of (x,y) space.  Bounds are
% automatically sorted such that xb(2) > xb(1) and yb(2) > yb(1).
%
% See also Rectangle, select, view
%

%
% created September 26, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=define(object,bound)

% manage input
assert(nargin == 2,'ERROR: invalid number of inputs');
assert(isnumeric(bound),'ERROR: invalid bound value');

default=report(object);
switch object.Mode
    case 'x'
        default=default(1:2);
    case 'y'
        default=default(3:4);
        
end
assert(numel(bound) == numel(default),...
    'ERROR: invalid bound value for %s mode',object.Mode);
k= isnan(bound);
bound(k)=default(k);

for n=1:2:numel(bound)
    k=n:n+1;
    temp=sort(bound(k));
    %assert(temp(2) > temp(1),'ERROR: bound values must be distinct');
    bound(k)=temp;
end

object.Data=reshape(bound,[1 numel(bound)]);

end