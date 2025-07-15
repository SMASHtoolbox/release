% DELETEPREDICTIONANDRESULTS - delete prediction and results
%
% This method deletes predictions and/or results
%
% Usage:
%   >> obj = deletePredictionAndResults(obj)
%   >> obj = deletePredictionAndResults(obj, 'p')
%       -> Delete predictions only
%   >> obj = deletePredictionAndResults(obj, 'r')
%       -> Delete results only
%
% created May, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = deletePredictionAndResults(obj, varargin)

pFlag = true;
rFlag = true;

if nargin > 1
    if strcmpi(varargin{1}(1), 'p')
        rFlag = false;
    elseif strcmpi(varargin{1}(1), 'r')
        pFlag = false;
    end
end

if pFlag
    obj.prediction.s = [];
    obj.prediction.lambdaSol = [];
    obj.prediction.spotLocations = [];
    obj.prediction.twoTheta = [];
    obj.prediction.I = [];
    obj.prediction.hkl = [];
    obj.prediction.d = [];
    obj.prediction.F_abs = [];
    obj.prediction.F = [];
    obj.prediction.m = []; 
end

if rFlag    
    obj.results.twoTheta = nan;
    obj.results.normalizedIntensity = nan;
    obj.results.normalization = struct;
end

end