% fft Fast Fourier Transform with digital window
%
% This method performs a Fast Fourier Transform with a digital window.
%    [transform,frequency]=fft(object,signal);
% The input "signal" can be numeric array of any size; arrays with fewer
% elements than the SamplePoints property are padded with zeros, and larger
% arrays are trimmed to that length.
%
% The output "transform" is a complex array of amplitudes at the locations
% specified by the output "frequency", which is normalized by the sample
% rate.  The full transformation is calculated by default, i.e. frequency
% runs from -1/2 to +1/2.  Passing an optional third input argument:
%    [transform,frequency]=fft(object,signal,'full'); % default
%    [transform,frequency]=fft(object,signal,'positive');
% allows the transform to be limited to positive frequencies only.
%
% When no output is requested:
%    fft(object,...);
% the complex transform is plotted in a new figure window.
% Omitting the signal input or passing an empty array:
%    [...]=fft(object);
%    [...]=fft(object,[],mode);
% uses a constant signal with amplitude 1.  The result is the window's
% Fourier transform centered at f=0.
%
% NOTE: this method uses a phase correction to the standard fft
% calculation.  Transform amplitude is *not* affected by this correction.
%
% See also DigitalWindow
%
%
function varargout=fft(object,signal,mode)

% manage input
N=object.SamplePoints;
if (nargin < 2) || isempty(signal)
    signal=ones([N 1]);
else
    assert(isnumeric(signal),'ERROR: signal must be numeric');
    if numel(signal) < N
        signal(N)=0;
    elseif numel(signal) > N
        warning('Trimming signal to %d sample points',N);
        signal=signal(1:N);
    end
end

if (nargin < 3) || isempty(mode)
    mode='full';
else
    assert(ischar(mode),'ERROR: invalid mode');
    assert(strcmpi(mode,'positive') || strcmpi(mode,'full'),...
        'ERROR: mode must be ''positive'' or ''full''');
    mode=lower(mode);
end

% raw transform and frequency arrays
N2=object.TransformPoints;
transform=fft(object.Data.*signal,N2)/(N-1);

switch mode
    case 'full'
        frequency=(-N2/2):(+N2/2-1);
        transform=fftshift(transform);
    case 'positive'
        frequency=0:(N2/2);
        transform=transform(1:(N2/2+1));
end
frequency=frequency(:)/N2;

% phase correction
correction=exp(1i*pi*(N-1)*frequency);
transform=transform.*correction;

% manage output
if nargout == 0
    figure();
    plot(frequency,real(transform),frequency,imag(transform));
    xlabel('Normalized frequency');
    ylabel('Transform amplitude');
    legend('Real','Imaginary')
    title(object.Name,'FontWeight','normal');
    return
end

varargout{1}=transform;
varargout{2}=frequency;

end