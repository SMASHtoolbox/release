% GENERATEHKL - generate hkl values
%
% This method generates hkl values needed for checking predicted patterns
%
% Usage:
%   >> obj = generatehkl(obj)
%   >> obj = generatehkl(obj, 'simulation')
%
% created October, 2023 by Nathan Brown (Sandia National Laboratories)
%
function obj = generatehkl(obj, varargin)

simFlag = false;
if nargin > 1 && strcmpi(varargin{1}(1), 's')
    simFlag = true;
end

if simFlag
    maxhkl = obj.simulation.max_hkl;
else
    maxhkl = obj.prediction.max_hkl;
    obj = deletePredictionAndResults(obj, 'p');
end

maxhkl = floor(maxhkl);
n = 2*maxhkl+1;
seed = -maxhkl:maxhkl;

hkl_1 = seed.*ones(n^2,n);
hkl_2 = repmat(seed,1,n).*ones(n,n^2);
hkl_3 = repmat(seed,1,n^2);
hkl = [hkl_1(:), hkl_2(:), hkl_3(:)];
hkl(~any(hkl,2),:) = []; % remove trivial (0,0,0)

if simFlag
    obj.simulation.hkl = hkl;
else
    obj.prediction.hkl = hkl;
end

end