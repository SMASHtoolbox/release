% reset Reset measurement
%
% This method resets measured signals
%    object=reset(object,data);
% The input "data" must be a SignalGroup object.
%
% Labels, parameters, ranges, and noise levels are preserved *if* the number
% of measurements does not change.  Specifying a different number of
% measurements changes these properties to an appropriate default state.
%
% See also RedundantSignal
%

%
% created February 1, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function object=reset(object,source)

Mold=object.NumberSignals;
assert((nargin == 2) && isa(source,'SMASH.SignalAnalysis.SignalGroup'),...
    'ERROR: invalid input');
M=source.NumberSignals;
%assert(M >= 2,'ERROR: signal data is not redundant');
object.Measurement=source;
%object.Measurement.DataLabel='Measurement';

if isempty(Mold) || (M ~= Mold)
    % update labels
    label=cell(1,M);
    for m=1:M
        label{m}=sprintf('Signal %d',m);
    end
    object.Measurement.Legend=label;    
    % reset weights, parameters, etc.
    object.Parameter=[];
    object.Parameter=repmat([0 1 0],[M 1]);
    object.Range=[];
    object.Range=repmat([-inf +inf],[M 1]);
    object.NoiseRatio=[];
    object.NoiseRatio=ones([M 1]);
end

if strcmp(object.Status,'complete')
    object.Status='obsolete';
end

end