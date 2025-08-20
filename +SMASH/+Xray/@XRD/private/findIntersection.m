function [spotLoc, badInd, xy] = findIntersection(s, planeNormal, ...
    planeLoc, crystalLoc, dist, n, im)

t_int = sum(planeNormal .* (planeLoc - crystalLoc), 2) ./ ...
    sum(planeNormal .* s, 2);
spotLoc = crystalLoc + t_int.*s;

% find rays that don't hit the detector. negative is backscattering, inf is
% parallel, and nan is just in case (but shouldn't ever happen). I'm
% eliminating backscattering due to my interpretation of Pecharsky pg
% 154-155, which shows that backward cones are just those with 2theta > 90
% and not mirrored forward cones caused by backscattering of 2theta < 90
% diffraction

badInd = t_int < 0 | isinf(t_int) | isnan(t_int);

switch isempty(n)
    case false % rectangle
        xy = [sum((spotLoc - planeLoc) .* n(2,:), 2), ... % along width
            sum((spotLoc - planeLoc) .* n(1,:), 2)]; % along height
        badInd = badInd | abs(xy(:,1,:)) > dist(2) | abs(xy(:,2,:)) > dist(1);
        if ~isnumeric(im) && any(im.Data == 0, 'all') % account for masked spots on detector
            xedge = linspace(-dist(2),dist(2),numel(im.Grid1));
            yedge = linspace(-dist(1),dist(1),numel(im.Grid2));
            [~, ~, ~, binX, binY] = histcounts2(...
                reshape(xy(:,1,:), [numel(xy)/2, 1, 1]), ...
                reshape(xy(:,2,:), [numel(xy)/2, 1, 1]), ...
                xedge, yedge);
            binX(binX == 0) = 1;
            binY(binY == 0) = 1;
            ind = im.Data(sub2ind(size(im.Data),binY,binX)) == 0;
            ind = reshape(ind, size(xy,1), 1, size(xy,3));
            badInd = badInd | ind;
        end
        if size(badInd,3) == 1 % simulation or single-crystal
            xy(badInd,:) = [];
        end
    case true % circle
        distRadius = vecnorm(spotLoc - planeLoc, 2, 2);
        badInd = badInd | distRadius > dist(1);
        xy = [];
end

end