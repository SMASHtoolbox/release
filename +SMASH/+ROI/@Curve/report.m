% report Report curve coordinates
%
% This method returns curve coordinates and widths as separate arrays.
%    [value,width,location]=report(object);
% Passing a second input:
%    [value,width]=report(object,location);
% interpolates the curve value and width at the requested location(s).
%
% See also Points, define, view
%

%
% created October 3, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function [value,width,location]=report(object,location)

if isempty(object.Data)
    value=[];
    width=[];
    location=[];
    return
end

% manage input
if (nargin <  2) || isempty(location)
    switch object.Mode
        case 'x'
            location=object.Data(:,1);
        case 'y'
            location=object.Data(:,2);
    end
end
assert(isnumeric(location) && all(isfinite(location)),...
    'ERROR: invalid location(s) requested');

% look up values/widths
Nrows=size(object.Data,1);
switch object.Mode
    case 'x'
        if Nrows > 1
            value=interp1(object.Data(:,1),object.Data(:,2),location);
            width=interp1(object.Data(:,1),object.Data(:,3),location);
        else
            value=object.Data(:,2);
            width=object.Data(:,3);
        end
    case 'y'
        if Nrows > 1
            value=interp1(object.Data(:,2),object.Data(:,1),location);
            width=interp1(object.Data(:,2),object.Data(:,3),location);
        else
            value=object.Data(:,1);
            width=object.Data(:,3);
        end
end

end