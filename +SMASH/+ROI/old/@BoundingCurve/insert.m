% insert Manually insert Bounding Curve points
%
% This method inserts points into a BoudingCurve object.
%     >> object=insert(object,table);
% The insertion table is typically a Nx3 array of [x y width]
% values.  If the object's DefaultWidth property is specified, the third
% column can be omitted.
%
% Inserted points are automatically sorted by x- or y-value based on the
% object's Direction property.
%
% See also BoundingCurve, define, remove
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=insert(object,data)

% handle input
assert(isnumeric(data),'ERROR: invalid data');
[M,N]=size(data);
if N==2
    assert(~isempty(object.DefaultWidth),...
        'ERROR: no DefaultWidth specified');
    data(:,3)=object.DefaultWidth;
    N=3;
end
assert((M>=1) & (N==3),'ERROR: invalid data');
data(:,3)=abs(data(:,3)); % force positive widths

% merge and sort data
data=[object.Data; data];
switch object.Direction
    case 'horizontal'
        data=sortrows(data,1);
    case 'vertical'
        data=sortrows(data,2);
end
object.Data=data;

end