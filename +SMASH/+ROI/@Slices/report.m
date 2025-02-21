% report Report slice coordinates
%
% This method returns slice coordinates as a one-column table of x or y
% values depending on the mode ('x' or 'y').
%    table=report(object);
%
% See also Slices, define, view
%

%
% created February 28, 2018 by Justin Brown (Sandia National Laboratories)
% - modification of Points.define
%
function data=report(object)

assert(isscalar(object),...
    'ERROR: reports must be generated one region at a time');

data=object.Data;

switch object.Mode
    case 'x'
        data = data(:,1);
    case 'y'
        data = data(:,2);
end

end