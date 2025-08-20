% testColor Test color value
%
% This function determines if a specified value is a valid color
% specification.
%     >> result=testColor(value)
% The output "result" is true if the input value is:
%     -A three-column array of values in the range [0 1].
%     -A short/long color name recognized by MATLAB.
%           'y', 'yellow'
%           'm', 'magenta'
%           'c', 'cyan'
%           'r', 'red'
%           'g', 'green'
%           'b', 'blue'
%           'w', 'white'
%           'k', 'black'
%
% See also General
%

%
% created December 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function result=testColor(value)

% handle input
assert(nargin==1,'ERROR: invalid number of inputs');

% test value
result=false;
if isnumeric(value)
    if (numel(value)==3) && all(value>=0) && all(value<=1)
        result=true;
    end
    return
end

if ischar(value)
    switch lower(value)
        case {'y','yellow'}
            result=true;
        case {'m','magenta'}
            result=true;
        case {'c','cyan'}
            result=true;
        case {'r','red'}
            result=true;
        case {'g','green'}
            result=true;
        case {'b','blue'}
            result=true;
        case {'w','white'}
            result=true;
        case {'k','black'}
            result=true;
        case 'none'
            result=true;
    end
    return
end

end