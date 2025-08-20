% ROTATE Rotate an ImageGroup object
%
% This method rotates the data and grid in an ImageGroup object.
% The default call opens an interactive GUI (at the moment, the first image
% is always called for the GUI).
%     object=rotate(object) or object=rotate(object,'gui');
%
% Specific calls can also be made:
%     object=rotate(object,angle); 
% The angle theta (in degrees) is positive for counter-clockwise rotations.
% NOTE:
%     -Cumulative operations should be avoided.  For example, a 45 degree
%     rotation is preferable to 25 degrees followed by 20 degrees.
%     -Rotation is perfectly reversible.  Rotation by +theta and -theta
%     produces a slightly different result than the original image.
%
% Exact 90 degree rotations can also be specified.
%    object=rotate(object,'left'); % counter-clockwise
%    object=rotate(object,'right'); % clockwise
% These rotations can be used cumaltively and are reversible.
% By default, these operation recenter the origin of the grid. If you do
% not want this, add the extra tag 'persist'
%   object=rotate(object,'left','persist');
%
% See also ImageGroup, flip
%

% created July 27, 2012 by Daniel Dolan (Sandia National Laboratories)
% revised December 28, 2012 by Daniel Dolan
%   -added rotation by a specified angle
% modified December 2, 2014 by Tommy Ao (Sandia National Laboratories)
%   -fixed Grids to match left and right rotations 
% modified August 21, 2015 by Daniel Dolan
%   -major revision to continuous rotation algorithm (twist)
% modified February 7, 2016 by Daniel Dolan
%   -added interactive rotation
% modified February 8, 2016 by Daniel Dolan
%   -interactive rotation is now the default case
% modified March 23, 2016 by Sean Grant (Sandia National Laboratories/UT)
%   -changed for ImageGroup
function object=rotate(object,argument,extra)

% handle input
if (nargin<2) || isempty(argument)  
    argument='gui';
end

if (nargin<3)
    extra=[];
end

% apply rotation
if isnumeric(argument)
    object=verifyGrid(object);
    object=twist(object,argument);
elseif strcmpi(argument,'gui')
    object=rotateGUI(object);
else
    if strcmpi(extra,'persist')
        %do nothing
    else
        %object=twist(object,0);
        % This needs to be looked at, consecutive uses buffer the edge too
        % much.
    end
    x=object.Grid1;
    y=object.Grid2;
    xlabel=object.Grid1Label;
    ylabel=object.Grid2Label;
    switch lower(argument)
        case {'left','counter-clockwise','counterclockwise'} 
            object.Data=permute(object.Data,[2 1 3]);
            %object=flip(object,'Grid2');
            x=x(end:-1:1);
        case {'right','clockwise'}
            %object=flip(object,'Grid2');
            object.Data=permute(object.Data,[2 1 3]);
            y=y(end:-1:1);
        otherwise
            error('ERROR: invalid input argument for rotation');
    end
    object.Grid1=transpose(y);
    object.Grid2=transpose(x);
    object.Grid1Label=ylabel;
    object.Grid2Label=xlabel;
end

object.ObjectHistory=object.ObjectHistory(1:end-1);
object=updateHistory(object);
end