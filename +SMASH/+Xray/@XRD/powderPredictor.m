% POWDERPREDICTOR - find predicted powder diffraction pattern
%
% This method predicts the powder diffraction pattern
%
% Usage:
%   >> obj = powderPredictor(obj)
%   >> obj = powderPredictor(obj, 'simulation')
%
% Note: The structure factor is computed with both normal and anamalous 
%    scattering factors and accounts for occupancy. In order to match 
%    VESTA's documented calculation, F is not corrected for differences 
%    between atomic and ionic scattering factors and is not corrected for 
%    temperature (aka atomic displacement). Computation of F was found to 
%    match that of VESTA to within <1% in almost all cases. In cases for 
%    which the match is not <1%, a transcription error made by the VESTA 
%    developers from their scattering factor source to the code can be 
%    identified (e.g. compare VESTA's a1 coefficient for V with that listed 
%    in their source, doi: 10.1107/S0108767394013292). The intensity
%    computations will differ from VESTA unless the Lorentz option is set
%    to 'slit' (not correct for most DMP applications). The intensity is 
%    also not corrected for absorption, extinction, or preferred 
%    orientation.
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = powderPredictor(obj, varargin)

% parse inputs (enables direct editing of obj to reduce number of variables
% in simulation)

simFlag = false;
fieldName = 'prediction';
if nargin > 1 && strcmpi(varargin{1}(1), 's')
    simFlag = true;
    fieldName = 'simulation';
end

% extract small values (big ones stay in obj to reduce number of variables
% in simulation)

V = obj.crystal.volume;
S11 = obj.crystal.dCalcs.S11;
S22 = obj.crystal.dCalcs.S22;
S33 = obj.crystal.dCalcs.S33;
S12 = obj.crystal.dCalcs.S12;
S23 = obj.crystal.dCalcs.S23;
S13 = obj.crystal.dCalcs.S13;
eName = obj.crystal.elementNames;
uvw = obj.crystal.elementLocations;
g = obj.crystal.elementOccupancies;

% compute d-spacing and twoTheta

d = (V^-2 * (S11*obj.(fieldName).hkl(:,1).^2 + ...
    S22*obj.(fieldName).hkl(:,2).^2 + S33*obj.(fieldName).hkl(:,3).^2 + ...
    2*S12*obj.(fieldName).hkl(:,1).*obj.(fieldName).hkl(:,2) + ...
    2*S23*obj.(fieldName).hkl(:,2).*obj.(fieldName).hkl(:,3) + ...
    2*S13*obj.(fieldName).hkl(:,1).*obj.(fieldName).hkl(:,3))).^-0.5;
sinTheta = obj.(fieldName).lambdaSol/2./d;
if simFlag
    clear('d');
end

% remove non-physical values (this should only matter in powder
% diffraction)

if ~simFlag
    badInd = sinTheta > 1;
    obj.(fieldName).hkl(badInd,:) = [];
    d(badInd) = [];
    sinTheta(badInd) = [];
end

% compute structure factors

% note that this computation accounts for occupancy and anomalous
% scattering but does not account for the temperature (aka atomic
% displacement) factor or differences between ionic and atomic scattering
% factors (ions are assumed to have the same scattering factors as atoms)
% see ch. 9 of Pecharsky and Zavalij for more details

if ~simFlag || ~obj.simulation.uniformSpotIntensity

    F = zeros(size(obj.(fieldName).hkl, 1), 1); % column vector: one F for each hkl

    for ii = 1:length(eName)

        % compute atomic scattering factors (one for each hkl)

        [ai, bi, ci, Z, f1, f2, frel, fNT] = ...
            scatteringFactorComponents(eName{ii}, ...
            obj.(fieldName).lambdaSol);
        f0 = sum(ai.*exp(-bi.*(sinTheta./obj.(fieldName).lambdaSol).^2),2) + ci;
        f = f0 + f1 + frel - Z + 1i*f2 + fNT;
        clear('frel', 'fNT');

        % compute F

        F = F + sum(g(ii) * f .* exp(2*pi*1i*sum(obj.(fieldName).hkl .* ...
            permute(uvw{ii}, [3 2 1]), 2)), 3);
        clear('f');

    end

    F_abs = abs(F);

    if simFlag
        clear('F');
    end

    % remove values corresponding to structure factors equal to zero

    badInd = F_abs < 1e-8;
    F_abs(badInd) = [];
    sinTheta(badInd) = [];
    obj.(fieldName).hkl(badInd,:) = [];

    if simFlag
        obj.(fieldName).lambdaSol(badInd) = [];
        obj.(fieldName).xy(badInd,:) = [];
    else
        d(badInd) = [];
        F(badInd) = [];
    end

    if ~simFlag && strcmp(obj.prediction.type, 'single-crystal')
        obj.prediction.s(badInd, :) = [];
        obj.prediction.spotLocations(badInd,:) = [];
        obj.prediction.lambdaSol(badInd,:) = [];
    end

else

    obj.(fieldName).I = ones(size(sinTheta));

end

% compute intensities, accounting for LP factor and wavelength distribution
% see ch. 8 of Pecharsky and Zavalij for LP details and convention
%
% A couple of notes:
% 1) No L term for simulation and single-crystal - these are powder effects
% 2) For powder, I compute my own version of the slit correction in
%    generatePrediction
% 3) In the LP term, I drop constants that are destined to be
%    cancelled in the I/max(I) computation (except in the case of K = 0.5,
%    wherein an unnecessary constant is carried before being cancelled)

if ~simFlag || ~obj.simulation.uniformSpotIntensity
    obj.(fieldName).I = (1-obj.source.K + obj.source.K * ...
        cosd(2*asind(sinTheta)).^2 * cosd(obj.source.twoThetaM)^2) ...
        .* F_abs.^2;
end

if strcmpi(obj.prediction.type, 'powder')
    obj.(fieldName).I = obj.(fieldName).I .* ...
        (cosd(asind(sinTheta)) ./ sind(2*asind(sinTheta)));
end

if simFlag

    clear('sinTheta', 'F_abs');

    % evaluate pdf as a function of lambda or E (even if user didn't
    % request to calculate the intensity)

    if contains(obj.source.distributionDriver(1), 'E')
        dist = obj.source.EDistribution;
        obj.(fieldName).lambdaSol = obj.source.conversion ./ ...
            obj.(fieldName).lambdaSol; % convert to E without adding another large variable
        mu = obj.source.E;
    else
        dist = obj.source.lambdaDistribution;
        mu = obj.source.lambda;
    end

    if isnumeric(dist)
        if numel(dist) == 1 % Gaussian sigma
            p = ((1/(dist*sqrt(2*pi)))*exp(-0.5*((obj.(fieldName).lambdaSol-mu)/dist).^2));
        elseif numel(dist) == 2 % range of values
            p = ones(size(obj.(fieldName).lambdaSol));
            p(obj.(fieldName).lambdaSol > max(dist) | ...
                obj.(fieldName).lambdaSol < min(dist)) = 0;
        else % interpolation with raw data
            p = interp1(dist(:,1), dist(:,2), obj.(fieldName).lambdaSol, 'linear', 0);
        end
    elseif contains(class(dist), 'prob') % pd object
        p = pdf(dist, obj.(fieldName).lambdaSol);
    else % function handle or curve fit (not recommended)
        warning('Unrecommended distribution input may produce unexpected results')
        p = dist{1}(obj.(fieldName).lambdaSol) - dist{2}; % dist{2} is offset
    end
    obj.(fieldName).lambdaSol = 'deleted to save space';

    % scale intensity by pdf (normalization happens in runSimulation)

    obj.(fieldName).I = obj.(fieldName).I.*p;

    % eliminate super small values

    badInd = obj.(fieldName).I/max(obj.(fieldName).I) < 1e-8 | isnan(obj.(fieldName).I);
    obj.(fieldName).I(badInd) = [];
    obj.(fieldName).hkl(badInd,:) = [];
    obj.(fieldName).xy(badInd,:) = [];

end

% populate object

if ~simFlag
    obj.prediction.twoTheta = 2*asind(sinTheta);
    obj.prediction.I = obj.prediction.I / max(obj.prediction.I);
    obj.prediction.d = d;
    obj.prediction.F_abs = F_abs;
    obj.prediction.F = F;
end

end