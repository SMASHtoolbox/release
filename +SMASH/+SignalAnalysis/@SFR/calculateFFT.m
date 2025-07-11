% calculateFFT Perform FFT calculation
%
% This *static* method calculates the Fast Fourier Transform (FFT) of a
% signal.
%    [fn,power,amplitude]=SFR.calculateFFT(signal,N2,span);
% The input "signal" defines the signal of interest.  The input "N2"
% indicates the number of transform points over all frequencies; this value
% is automatically rounded up to the next power of 2 and is always >= the
% number of signal points.  The input "span" selects the transform
% frequency span: 'positive' (default) or 'all'.
%
% The output "fn" is an array of normalized frequency values.  The output
% "power" is the power spectrum, where every array element is real and
% non-zero. The output "amplitude" is a complex-valued array.
%
% See also SFR
%
function [fn,power,amplitude]=calculateFFT(signal,N2,span)

% manage input
assert(nargin >= 1,'ERROR: insufficient input');
assert(isnumeric(signal),'ERROR: signal must be a numeric array');
N=numel(signal);

if (nargin < 2) || isempty(N2)
    N2=N;
else
    assert(testNumber(N2) && (N2 > 0),'ERROR: invalid N2 value');
end
N2=pow2(nextpow2(max(N2,N)));

if (nargin < 3) || isempty(span)
    span='positive';
else
    assert(ischar(span) && (strcmpi(span,'positive') || strcmpi(span,'all')),...
        'ERROR: frequency span must be ''positive'' or ''all''');
    span=lower(span);
end

% calculate requested FFT
amplitude=fft(signal(:),N2);

if strcmpi(span,'positive')
    fn=(0:N2/2)/N2;
    M=N2/2+1;
    amplitude=amplitude(1:M);
    AreaCorrection=2;
else
    fn=((-N2/2):(N2/2-1))/N2;
    amplitude=fftshift(amplitude);
    AreaCorrection=1;
end
fn=cast(fn(:),'like',signal);
power=real(amplitude).^2+imag(amplitude).^2;

% normalization 
area1=etrapz(signal.*signal,[-0.5 0.5]);
area2=etrapz(power,[fn(1) fn(end)])*AreaCorrection;
ratio=area1/area2;
power=power*ratio;

% corrected amplitude
if nargout < 3
    return
end

PhaseCorrection=exp(1i*pi*fn*(N-1));
amplitude=amplitude.*PhaseCorrection*sqrt(ratio);

end