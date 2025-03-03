% report Report coordinates
% 
% This method returns rectangle bounds as a four-element array.
%    table=report(object); % output is [x1 x2 y1 y2]
%
% See also Rectangle, define, view
%

%
% created September 28, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function data=report(object)

assert(isscalar(object),...
    'ERROR: reports must be generated one region at a time');

switch object.Mode
    case 'xy'
        data=object.Data;
    case 'x'
        data=[object.Data -inf +inf];
    case 'y'
        data=[-inf +inf object.Data];
end

end