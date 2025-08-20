% convert Convert point management mode
%
% This function converts a Points object from one mode to another.
%    object=convert(object,mode);
% If no mode is specified, 'open' mode is selected by default.
%
% In many cases, changing modes afects how points are displayed but not the
% stored data.  An important exception are conversions to 'convex' mode,
% which eliminates all points inside a closed boundary of the outermost
% points.  This information is *not* retained and cannot be recovered by
% converting from 'convex' to any of the other modes.  These conversions
% generate a warning.
%
% See also Points, define, select, view
%

%
% created September 24, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=convert(object,mode)

assert(isscalar(object),...
    'ERROR: conversions must be done one region at a time');

% manage input
if (nargin < 2) || isempty(mode)
    mode='open';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case object.ValidModes
        % continue   
    otherwise
        error('ERROR: invalid mode');
end

% convert object
if strcmp(object.Mode,mode)
    return
end

old=report(object);
object.Mode=mode;
new=report(object);
if size(new,1) < size(old,1)
    warning('SMASH:Points',...
        'Interior points eliminated during mode conversion');
end
object=define(object,new);

end