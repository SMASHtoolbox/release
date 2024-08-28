% probe Probe limits of a BoundingCurve
%
% This function returns the lower/upper limits of a BoundingCurve at
% specified locations.
%     >> [low,high]=probe(object,location);
% For horizontal curves, "location" is an array of x values where the
% lower/upper y-values are determiend.  For vertical curves, "location"
% is an array of y values where lower/upper x-values are determined.
% Linear interpolation is used to at intermediate locations.
%
% If no locations are requested, the method returns the bounding curve
% data.
%     >> [x,y,width]=probe(object);
%
% See also BoundingCurve
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=probe(object,location)

% handle input
if nargin<2 
    varargout{1}=object.Data(:,1);
    varargout{2}=object.Data(:,2);
    varargout{3}=object.Data(:,3); 
    return
elseif isempty(location)
    assert(~isempty(object.Data),'ERROR: no data found');
    switch object.Direction
        case 'horizontal'
            location=object.Data(:,1);
        case 'vertical'
            location=object.Data(:,2);
    end
end
location=location(:);

% interpolate dynamic boundaries
if isempty(object.Data)
    varargout{1}=NaN;
    varargout{2}=NaN;
else
    switch object.Direction
        case 'horizontal'
            center=interp1(object.Data(:,1),object.Data(:,2),location);
            width=interp1(object.Data(:,1),object.Data(:,3),location);
        case 'vertical'
            center=interp1(object.Data(:,2),object.Data(:,1),location);
            width=interp1(object.Data(:,2),object.Data(:,3),location);
    end
    varargout{1}=center-width;
    varargout{2}=center+width;
end

end