% hilbert Calculate Hilbert transform
%
% This method generates a complex quadrature signal from a real signal
% using a Hilbert transform.  By default, frequencies below 1% of the
% Nyquist limit are removed by a low pass filter.
%    new=hilbert(object);
% The characteristic width (tanh function) of the low pass filter can also
% be specified explicitly.
%    new=hilbert(object,width);
% Widths should be specified in the inverse units of the signal time base.
% For example, time in seconds means that frequency is specified in hertz.
% 
% See also Signal, fft
%

%
% created August 9, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function result=hilbert(object,width)

% manage input
if (nargin<2) || isempty(width)
    width=nan;
end
assert(isnumeric(width) && isscalar(width),'ERROR: invalid cutoff width');

%% transform signal
object=makeGridUniform(object);
[time,signal]=limit(object);

numpoints=numel(signal);
N2=pow2(nextpow2(numpoints));
T=(time(end)-time(1))/(numpoints-1);

frequency=(-N2/2):(+N2/2-1);
frequency=frequency(:)/(N2*T);
transform=fft(signal,N2);
transform=fftshift(transform);

if isnan(width)
    width=0.01*frequency(end);
end

% unshifted component
transfer=abs(tanh(frequency/width));
signal1=transform.*transfer;
signal1=ifftshift(signal1);
signal1=ifft(signal1,'symmetric');
signal1=real(signal1(1:numpoints));

% shifted component
transfer=-1i*tanh(frequency/width);
signal2=transform.*transfer;
signal2=ifftshift(signal2);
signal2=ifft(signal2,'symmetric');
signal2=real(signal2(1:numpoints));

%% manage output
result=SMASH.SignalAnalysis.Signal(time,signal1+1i*signal2);

end