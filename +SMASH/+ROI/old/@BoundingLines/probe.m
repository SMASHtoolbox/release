% probe Probe bound limits
%
% This method probes the limits specified in a BoundingLines object.
%     >> limit=probe(object);
%     >> limit=probe(object,locations);
% The first example returns the lower and upper limits as a 1x2 array.  The
% second example replicates the array to match the number of elements from
% the "location" input.
%
% See also BoundingLines
%

%
% created November 14, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function limit=probe(object,location)

% handle input
if (nargin<2) || isempty(location)
    limit=object.Data;
    return
end
location=location(:);

% manage boundaries
limit=nan(numel(location),2);
limit(:,1)=repmat(object.Data(1),size(location));
limit(:,2)=repmat(object.Data(2),size(location));

end