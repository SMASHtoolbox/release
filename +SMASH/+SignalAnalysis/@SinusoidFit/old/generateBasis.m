% UNDER CONSTRUCTION
function [positive,negative]=generateBasis(object,index)

% manage input
assert(object.NumberSinusoids > 0,'ERROR: no sinusoids added');
if (nargin < 2) || isempty(index)
    index=1;
else
    valid=1:object.NumberSinusoids;
    assert(isnumeric(index) && isscalar(index) && any(index == valid),...
        'ERROR: invalid sinusoid index');    
end

% generate basis
sinc=@(arg) SMASH.SignalAnalysis.sinc(arg,'normalized');

f0=object.Parameter(index,1);
x=object.Duration*(object.Spectrum.FrequencyGrid-f0);
positive=sinc(x)/2+sinc(x-1)/4+sinc(x+1)/4;

x=object.Duration*(object.FrequencyGrid+f0);
negative=sinc(x)/2+sinc(x-1)/4+sinc(x+1)/4;

end