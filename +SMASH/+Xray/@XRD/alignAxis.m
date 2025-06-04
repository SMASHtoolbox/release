% ALIGNAXIS - align a specified crystal axis to a specified direction
%
% This method aligns a specified crystal axis (specified via an index of 1,
% 2, or 3) to a specified direction. The specified direction may be a 
% 3-element vector, a string denoting the name of a CS axis ('x', 'y', or 
% 'z'), or an XRD object and corresponding specified axis index.
%
% Usage:
%   >> obj = alignAxis(obj, axisIndex, targetVector)
%   >> obj = alignAxis(obj, axisIndex, targetCSAxisName)
%   >> obj = alignAxis(obj, axisIndex, targetObject, targetObjectAxisInd)
%
% Example: align c-axis of input object crystal to the c-axis of another:
%   >> obj = alignAxis(obj, 3, targetObject, 3)
%
% created August, 2024 by Nathan Brown (Sandia National Laboratories)
%
function [obj, ang, rotVec] = alignAxis(obj, ind, target, varargin)

% parse inputs

if isa(target, 'char') || isa(target, 'string')
    switch lower(target)
        case 'x'
            target = [1 0 0];
        case 'y'
            target = [0 1 0];
        case 'z'
            target = [0 0 1];
        otherwise
            error('Invalid input')
    end
elseif isnumeric(target)
    assert(numel(target)==3, 'Invalid input');
    target = target(:)'; % necessary for changeObject
elseif isa(target, 'SMASH.Xray.XRD')
    assert(~isempty(varargin), 'Must specify target crystal axis index');
    target = target.crystal.vectors(varargin{1},:);
end

% rotate crystal about the axis normal to the plane containing the initial
% and target vectors by the angle between them

init = obj.crystal.vectors(ind,:);
ang = real(acosd(dot(init,target)/(norm(init)*norm(target)))); % sometimes get small complex numbers so have to take real
if abs(ang) < 1e-6 || abs(ang-180) <1e-6
    if init(3) == 0
        rotVec = [0 0 1];
    else
        rotVec = [1 1 (-init(1)-init(2))/init(3)];
    end
else
    rotVec = cross(init,target);
end
obj = changeObject(obj, 'crystal', 'orientation', ang, rotVec);

end