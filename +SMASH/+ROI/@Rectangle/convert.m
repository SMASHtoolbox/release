% convert Convert point management mode
%  
% This function converts a Rectangle object from one mode to another.
%      object=convert(object,mode);
% If no mode is specified, 'xy' mode is selected by default.
%
% See also Rectangle, define, select, view
%

%
% created September 28, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=convert(object,mode)

assert(isscalar(object),...
    'ERROR: coversions must be done one region at a time');

% manage input
if (nargin < 2) || isempty(mode)
    mode='xy';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case object.ValidModes
        % continue
    otherwise
        error('ERROR: invalid mode');
end


% perform conversion
data=report(object);
object.Mode=mode;
switch mode
    case 'xy'
        object.Data=data;
    case 'x'
        object.Data=data(1:2);
    case 'y'
        object.Data=data(3:4);
end

end