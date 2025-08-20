% report Report point coordinates
%
% This method returns point coordinates as a two-column table of (x,y)
% values.
%    table=report(object);
%
% See also Points, define, view
%

%
% created September 26, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function data=report(object)

assert(isscalar(object),...
    'ERROR: reports must be generated one region at a time');

data=object.Data;
switch object.Mode
    case {'open' 'connected' 'closed'}
        % nothing to do
    case 'convex'
        if size(data,1) >= 4
            k=convhull(data(:,1),data(:,2));
            k=k(1:end-1);
            data=data(k,:);
        end
end

end