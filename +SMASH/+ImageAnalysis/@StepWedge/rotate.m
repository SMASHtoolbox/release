% rotate Rotate measured image
%
% This method rotates step wedge measurement.  The image can be rotated by
% a specified angle (in degrees):
%    object=rotate(object,theta);
% or automatically.
%    object=rotate(object,'auto');
% Automatic rotation forces the image's longest dimension to be horiztonal,
% with increasing intensity along the horizontal/vertical grid.  NOTE:
% vertical grids increases from top to bottom by default, so auto-rotated
% images may appear inverted.
%
% Areas in the rotated image that originate outside of the original image
% are assigned with NaN values.  A different value can be assigned to these
% regions by passing a third input argument.
%    object=rotate(object,theta,value);
%
% See also StepWedge, view
%

%
% created August 26, 2016 by Daniel Dolan (Sandia National Laboratory)
%
function object=rotate(object,theta,value)

% manage input
if (nargin<2) || isempty(theta)
    theta='gui';
end

if nargin<3
    value=[];
end

% perform rotation
if strcmpi(theta,'auto')
    % make the long side horizontal
    [Ly,Lx]=size(object.Measurement.Data);
    if Ly>Lx
        %object.Measurement.Data=transpose(object.Measurement.Data);
        object.Measurement=rotate(object.Measurement,'right');
    end
    % intensity increases to the horizontal position
    temp=mean(object.Measurement,'Grid2');
    param=polyfit(temp.Grid,temp.Data,1);
    if param(1)<0
        object.Measurement=flip(object.Measurement,'Grid1');
    end
    % intensity increases with vertical position
    temp=mean(object.Measurement,'Grid1');
    param=polyfit(temp.Grid,temp.Data,1);
    if param(1)<0
        object.Measurement=flip(object.Measurement,'Grid2');
    end
else
    object.Measurement=rotate(object.Measurement,theta);
    if ~isempty(value)
        index=isnan(object.Measurement.Data);
        object.Measurement=replace(object.Measurement,value,index);
    end
end

end