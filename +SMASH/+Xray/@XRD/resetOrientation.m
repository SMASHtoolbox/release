% RESETORIENTATION - reset orientation to value at creation
%
% This method resets the orientation of the crystal or detector to the
% value that object had at its creation
%
% Usage:
%   >> obj = resetOrientation(obj, category)
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = resetOrientation(obj, category)

obj = deletePredictionAndResults(obj);
switch lower(category)
    case 'crystal'
        obj.crystal.vectors = obj.crystal.lengths' .* ...
            (obj.crystal.vectorsReference ./ ...
            vecnorm(obj.crystal.vectorsReference,2,2));
        obj.crystal.orientation = [0 0 0];
        obj.crystal.orientationReference = obj.crystal.orientation;
    case 'detector'
        obj.detector.planePoints = obj.detector.location + ...
            obj.detector.vecRef.*(obj.detector.size'/2);
        obj.detector.orientation = [0 0 0];
        obj.detector.orientationReference = obj.detector.orientation;
end

end