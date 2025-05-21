% define Manually define bound points
%
% This method defines BoundingCurve points with a data table.
%     >> object=define(object,table);
% The second input is typically a Nx3 table of data points specifying the
% horizontal position, vertical position, and width of the bounding curve.
% If the object's Default property has been defined, the last column can be
% omitted; all points are then assigned the default width.
%
% CAUTION: this method overwrites all curve data stored in an object!  To
% add new points instead of complete replacement, use the "insert" method.
%
% See also BoundingCurve, insert, remove, select
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=define(object,data)

% handle input
assert(nargin>=2,'ERROR: insufficient input');

% place data in object
if isempty(data)
    % do nothing
elseif size(data,2)==2
    assert(~isempty(object.DefaultWidth),...
        'ERROR: no DefaultWidth specified');
    data(:,3)=object.DefaultWidth;   
else
    assert(size(data,2)==3,'ERROR: invalid data');
end
data(:,3)=abs(data(:,3)); % force positive widths

switch object.Direction
    case 'horizontal'
        data=sortrows(data,1);
    case 'vertical'
        data=sortrows(data,2);
end

object.Data=data;

end