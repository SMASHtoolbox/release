% CALSOLVE - execute calibration
%
% This method employs a genetic algorithm to perform detector and crystal 
% calibrations. This method must be run after calPOI.
%
% Usage:
%   >> obj = calSolve(obj)
%
% created January, 2025 by Nathan Brown (Sandia National Laboratories)
%
function [obj, score, gaInfo] = calSolve(obj)

% input parsing

assert(~isempty(obj.calibration.poi), 'No points of interest')
if ~isa(obj.calibration.opts.gaOpts, 'optim.options.GaOptions')
    obj = changeObject(obj, 'calibration', 'opts', 'gaOpts', 'default');
    assert(isa(obj.calibration.opts.gaOpts, 'optim.options.GaOptions'), ...
        'Missing required toolbox to set up GA');
    disp('No GA options detected: applying defaults...');
end

% code

if contains(obj.calibration.type, 'detector')
    obj = changeObject(obj, 'prediction', 'type', 'powder');
    [x, score, gaInfo] = powderCal(obj);
    obj = changeObject(obj, 'detector', 'orientation', ...
        obj.detector.orientation + x(4:6));
    obj = changeObject(obj, 'detector', 'location', ...
        obj.detector.location + x(1:3));
else
    obj = changeObject(obj, 'prediction', 'type', 'single-crystal');
    [x, score, gaInfo] = crystalCal(obj);
    obj = changeObject(obj, 'crystal', 'orientation', ...
        obj.crystal.orientation + x(1:3));
    obj = changeObject(obj, 'crystal', 'lengths', ...
        obj.crystal.lengths * x(4));  % x(4) is vec% even though input bound is vol%
end

end

%% Geometry Calibration

function [x, fval, output] = powderCal(obj)

% parse bounds

ub = abs(obj.calibration.searchBounds);
lb = -1*ub;

% find predicted twoTheta on the detector and window down to either the
% first n values corresponding to the n regions (default) or to a
% user-specified index and then the first n values corresponding to the n
% regions

obj = generatePrediction(obj);
twoThetaPred = obj.prediction.twoTheta;
thetaInd = obj.calibration.opts.thetaInd;
if isnumeric(thetaInd)
    twoThetaPred = twoThetaPred(twoThetaInd);
end
poi = obj.calibration.poi;
assert(numel(twoThetaPred)>=size(poi,3), 'Prediction-Region Mismatch');
twoThetaPred = twoThetaPred(1:size(poi,3));

% find 3D poi coordinates

[~, poi] = findPixelCoordinates(obj, poi); % output is [pt reg xyz]

% find poi twoTheta and sort coordinates appropriately

s0 = obj.source.s0;
crystalCenter = reshape(obj.crystal.location, 1, 1, 3);
v = poi - crystalCenter;
s0temp = repmat(permute(s0,[3 1 2]), size(v,1), size(v,2), 1);
twoTheta = acosd(dot(v,s0temp,3) ./ (vecnorm(v,2,3) .* vecnorm(s0temp,2,3)));
[~, ind] = sort(mean(twoTheta, 1, 'omitnan'));
poi = poi(:,ind,:);

% set up and run optimization

planeCenter = reshape(obj.detector.location, 1, 1, 3); % make pagewise vector like crystalCenter
poi = reshape(poi, [], 1, 3); % every opts.maxPointNum row is a different region
twoThetaPred = permute(twoThetaPred, [3 2 1]); % each twoTheta now a different page

fun = @(in)powderOptFun(in, poi, s0, crystalCenter, planeCenter, ...
    twoThetaPred);
[x, fval, exitflag, output] = ga(fun, numel(lb), [], [], [], [], ...
    lb, ub, [], obj.calibration.opts.gaOpts);
close(findobj('Name', 'Genetic Algorithm'));

end

%% Geometry Calibration Optimization Function

function score = powderOptFun(in, poi, s0, crystalCenter, ...
    planeCenter, twoThetaPred)

% vectorization notes:
% don't flip input and output dimensions - this specific setup is necessary
% for some of the global solvers (they require each row to be a new guess)
% in: each row is a different guess, each column is a different parameter
% (in loc and rot order)
% score: each row is the score from each row from in (only at the output,
% note that I transpose at the very end to make this true)
% poi is set up so that each row is a peak point, each column
% is the result from applying each row of in, and each page is x,y,z.

dloc = permute(in(:,1:3), [3 1 2]);
drot = in(:,4:6)';

v = poi - planeCenter;
for ii = 1:size(drot,1) % you either loop or copy-paste three times
    u = zeros(size(v));
    u(:,:,ii) = 1;
    v = v.*cosd(drot(ii,:)) + cross(u,v,3).*sind(drot(ii,:)) + ...
        u.*dot(u,v,3).*(1-cosd(drot(ii,:)));
end
poi = v + planeCenter;
poi = poi + dloc;

% find 2theta and score result (equal weight to each line)
% score is absolute difference between actual and predicted 2theta (this
% seems to work better than using a percent difference)

v = poi - crystalCenter;
s0 = repmat(permute(s0,[3 1 2]), size(v,1), size(v,2), 1);
twoTheta = acosd(dot(v,s0,3) ./ (vecnorm(v,2,3) .* vecnorm(s0,2,3)));
twoTheta = permute(reshape(permute(twoTheta, [1 3 2]), ...
    [], numel(twoThetaPred), size(twoTheta,2)), [1 3 2]);
score = mean(mean(abs(twoTheta - twoThetaPred), 1, ...
    'omitnan'), 3, 'omitnan')';

end

%% Crystal Orientation Calibration

function [x, fval, output] = crystalCal(obj)

% parse bounds

bounds = abs(obj.calibration.searchBounds);
ub(1:3) = bounds(1:3);
ub(4) = (1+bounds(4))^(1/3); % convert from vol to vector
lb(1:3) = -1*bounds(1:3);
lb(4) = (1-bounds(4))^(1/3); % convert from vol to vector

% find 3D poi coordinates

[~, poi] = findPixelCoordinates(obj, obj.calibration.poi); % output is [pt reg xyz]
poi = permute(poi, [1 3 2]); % output is [pt xyz]

% pull out and compute needed variables

crystalCenter = obj.crystal.location;
planePoints = obj.detector.planePoints;
planeCenter = obj.detector.location;
v = obj.crystal.vectors;
s0 = obj.source.s0/norm(obj.source.s0);
vol = obj.crystal.volume;
lambdaRange = extractLambdaRange(obj);
switch obj.crystal.orientationSystem
    case 'xyz'
        u_base = eye(3);
    case 'abc'
        u_base = v ./ vecnorm(v,2,2);
end

% pull twoTheta from spots

s = poi - crystalCenter;
s = s./vecnorm(s,2,2);
twoTheta = acosd(dot(s,repmat(s0,size(s,1),1),2));

% generate twoTheta bounds to narrow hkl search
% currently assuming isotropic expansion/contraction bounds

obj = changeObject(obj, 'prediction', 'max_hkl', 10);
obj = generatehkl(obj);

obj1 = processImage(obj, 'delete');
obj1 = deleteSimulation(obj1);
obj1 = changeObject(obj1, 'prediction', 'type', 'powder');
obj1 = changeObject(obj1, 'prediction', 'option', 'allseparate');
obj1 = changeObject(obj1, 'prediction', 'max_hkl', 10);

obj1 = changeObject(obj1, 'source', 'lambda', min(lambdaRange));
obj2 = changeObject(obj1, 'source', 'lambda', max(lambdaRange));
obj1 = changeObject(obj1, 'crystal', 'lengths', ...
    ub(4)*obj1.crystal.lengths);
obj2 = changeObject(obj2, 'crystal', 'lengths', ...
    lb(4)*obj2.crystal.lengths);
obj1 = generatePrediction(obj1);
obj2 = generatePrediction(obj2);

twoTheta1 = obj1.prediction.twoTheta;
twoTheta2_temp = obj2.prediction.twoTheta;
hkl1 = obj1.prediction.hkl;
hkl2 = obj2.prediction.hkl;

% index possible hkls for each spot based on twoTheta

% obj2 should have fewer predictions because the larger wavelength pushes
% more of the twoTheta beyond 180 deg, so it's best to pad and align
% twoTheta2 to hkl1

[~, ia, ib] = intersect(hkl1, hkl2, 'rows');
twoTheta2 = inf(size(twoTheta1));
twoTheta2(ia) = twoTheta2_temp(ib);
hklInd = twoTheta >= twoTheta1' & twoTheta <= twoTheta2';
hkl = hkl1((sum(hklInd,1) > 0)',:);

% perform optimization

fun = @(in)crystalOptFun(in, v, crystalCenter, ...
    planePoints, planeCenter, hkl, s0, poi, lambdaRange, ...
    u_base, vol);
[x, fval, exitflag, output] = ga(fun, numel(lb), [], [], [], ...
    [], lb, ub, [], obj.calibration.opts.gaOpts);
close(findobj('Name', 'Genetic Algorithm'));

end

%% Crystal Orientation Calibration Optimization Function

function score = crystalOptFun(in, v, crystalCenter, ...
    planePoints, planeCenter, hkl, s0, poi, lambdaRange, u_base, vol)

% vectorization notes:
% don't flip input and output dimensions - this specific setup is necessary
% for some of the global solvers (they require each row to be a new guess)
% in: each row is a different guess, each column is a different parameter
% (in crystal orientation, lattice parameter ratio, detector position, 
% detector orientation order)
% score: each row is the score from each row from in
% poi is set up so that each row is a peak point and each
% column is x,y,z
% assumes s0 and u_base are already normalized

% crystal orientation, vector scale

crot = permute(in(:,1:3), [3 2 1]);
vecScale = permute(in(:,4), [2 3 1]);

% rotate the crystal about the CS or crystal axes (x,y,z or a,b,c order)

v = repmat(v,1,1,size(crot,3));
for ii = 1:3
    u = repmat(u_base(ii,:), size(v,1), 1, size(v,3));
    v = v.*cosd(crot(:,ii,:)) + cross(u,v,2).*sind(crot(:,ii,:)) + ...
        u.*dot(u,v,2).*(1-cosd(crot(:,ii,:)));
end

% change the crystal size

v = v.*vecScale;
vol = vol*vecScale.^3;

% compute s

H = hkl(:,1).*cross(v(2,:,:), v(3,:,:), 2)./vol + ...
    hkl(:,2).*cross(v(3,:,:), v(1,:,:), 2)./vol + ...
    hkl(:,3).*cross(v(1,:,:), v(2,:,:), 2)./vol;
a = sum(H.^2,2);
b = sum(2*H.*s0,2);
lambdaSol = -b./a;
s = s0 + H.*lambdaSol;

% find where each s strikes each detector (validated against Xray.XRD)

planeNormal = cross(planePoints(1,:,:) - planeCenter, ...
    planePoints(2,:,:) - planeCenter, 2);
planeNormal = repmat(planeNormal, size(s,1), 1, 1);
t_int = sum(planeNormal .* (planeCenter - crystalCenter), 2) ./ ...
    sum(planeNormal .* s, 2);
spotLoc = crystalCenter + t_int.*s;

% score the results (validated by hand)
% score is the 

badInd = lambdaSol < lambdaRange(1) | lambdaSol > lambdaRange(2) | ...
    isnan(lambdaSol);
spotLoc(repmat(badInd,1,3,1)) = inf;
score = inf(size(poi,1),1,size(spotLoc,3));
for ii = 1:size(poi, 1)
    score(ii,:,:) = min(sqrt(sum((spotLoc - ...
        poi(ii,:,:)).^2,2)), [], 1, 'omitnan');
end
score = permute(mean(score,1), [3 2 1]);

end