% setBandwidth Set measurement bandwidth
%
% This method sets the measurement bandwidth, i.e. the highest meaningful
% frequency.  The value can be specified directly:
%    setBandwidth(object,value);
% or transferred from another SFR object.
%    setBandwidth(object,source);
%
% See also SFR, estimateBandwidth
%

function setBandwidth(object,value)

nyquist=object.SampleRate/2;
if (nargin < 2) || isempty(value)
    value=nyquist;
elseif isobject(value) && isprop(value,'Bandwidth')
    value=value.Bandwidth;
else
    assert(testNumber(value) && (value > 0),...
        'ERROR: invalid bandwidth setting');
end

if value > nyquist
    warning('Reducing bandwith to Nyquist limit');
end

object.Bandwidth=value;

end