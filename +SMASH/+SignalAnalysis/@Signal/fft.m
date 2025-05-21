% fft Calculate Fast Fourier transforms
%
% This method calculates the spectrum of a Signal over the limited region.
% The calling syntax is:
%    >> [frequency,spectrum,option]=fft(object,name,value,...);
% where name/value pairs specify options for the FFT calculation.  Up to
% three output arguments are returned.
%    -"frequency" is an array of grid points where the spectrum is
%    calculated.
%    -"spectrum" is the calculated spectrum value at those grid points
%    -"option" is a structure describing all options (user-defined and
%    default) used in the calculation.
% Calling this method with no outputs causes the result to be plotted in a
% new figure.
%
% The digital window applied prior to the Fourier transform can be
% specified by name:
%    >> [...]=fft(object,'Window',name,...);
% where "name" can be 'boxcar', 'gaussian', 'Hamming', or 'Hann' (default).
% A cell array should be used to pass window parameters.
%    >> [...]=fft(object,'Window','gaussian',...); % window spans +/- 3 deviations
%    >> [...]=fft(object,'Window',{'gaussian' 5},...); % window spans +/- 5 deviations
% Windows can also be defined numerically:
%    >> [...]=fft(object,'Window',array,...);
% by passsing an array mathing the limited region size.
%
% The local DC level of the signal can be removed prior to the Fourier
% transform.
%    >> [...]=fft(object,'RemoveDC',true,...);
% The default state of 'RemoveDC' is false, which causes the DC level to be
% retained in the transform.
%
% The number of frequencies generated in the transform is controled by:
%    >> [...]=fft(object,'NumberFrequencies',value,...);
% Passing a single number defines the minimum number of frequencies,
% rounding up to the next power of two and zero padding as neccessary.
% Passing two numbers defines a minimum and maximum number of frequencies;
% if the transform exceeds this maximum, the result is interpolated onto a
% coarser frequency grid (preserving total area).
%
% The "spectrum" returned by this method is defined by:
%    >> [frequency,spectrum]=fft(object,'SpectrumType',choice,...);
% The default choice, 'power', returns the power spectrum (transform times
% its complex conjugate); 'power_dB' works in an similar fashion, mapping
% the results to a decibel scale.  Choosing "complex" returns the actual
% Fourier transform, which has both real and imaginary components.  A third
% choice, "phase", calculates the phase angle (in radians) of transform.
% Each choice of spectrum choice can be generated for 'positive' (default),
% 'negative', or 'all' frequencies.
%    >> [...]=fft(object,'FrequencyDomain',value,...);
%
% Options can be passed as a struction array:
%    >> [...]=fft(object,option);
% where the structure fields and values match the preceding discussion.
% This approach is convenient when calling the function multiple times with
% the same parameters.
%
% See also Signal
%

%%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised April 16, 2014 by Daniel Dolan
%    -support power (default), complex, and phase spectrum output
%    -support positive (default), negative, or all frequency output
%    -eliminated 'loose'/'strict' modes (all names must match exactly)
%    -added a phase correction factor to match analytic results
%    -revised help documentation
% revised May 5, 2014 by Daniel Dolan
%    -revised scaling to match Parseval's theorem
% revised November 11, 2014 by Daniel Dolan
%    -merged window management into a single input
% revised September 18, 2019 by Daniel Dolan
%    -removed normalization control, result automatically comply with Parseval's theorem
function varargout=fft(object,varargin)

%% manage option
option=struct('Window','Hann',...
    'RemoveDC',false,'NumberFrequencies',[100 inf],...
    'SpectrumType','power','FrequencyDomain','positive');
Narg=numel(varargin);
if Narg==1
    if isstruct(varargin{1})
        name=fieldnames(varargin{1});
        for k=1:numel(name)
            if strcmpi(name{k},'normalization')
                continue
            elseif isfield(option,name{k})
                option.(name{k})=varargin{1}.(name{k});
            else
                fprintf('Ignoring invalid option "%s\n',name{k});
            end
        end
    elseif isa(varargin{1},'SMASH.General.FFToptions')
        warning('off','MATLAB:structOnObject');
        option=struct(varargin{1});
        warning('on','MATLAB:structOnObject');
    else
        error('ERROR: invalid option specification');
    end
elseif rem(Narg,2)==0
    for n=1:2:Narg
        name=varargin{n};
        assert(ischar(name),'ERROR: invalid option name');
        if strcmpi(name,'normalization')
            continue
        elseif isfield(option,name)
            option.(name)=varargin{n+1};
        else
            fprintf('Ignoring invalid option "%s\n',name);
        end
    end
else
    error('ERROR: unmatched name/value pair');
end

%% verify uniform grid
object=makeGridUniform(object);

% extract region of interest
[time,signal]=limit(object);

%% verify options
% this could probably be moved to a function and bypassed when an option
% structure is passed
numpoints=numel(signal);
arg=0:(numpoints-1);
arg=arg/(numpoints-1);
if ischar(option.Window)
    name=option.Window;
    switch lower(name)
        case {'gaussian','gauss'}
            L=3;
            sigma=(arg(end)-arg(1))/(2*L); % three deviations in each direction
            mid=(arg(end)+arg(1))/2;
            option.Window=exp(-(arg-mid).^2/(2*sigma^2));
        case 'hamming'
            option.Window=0.54-0.46*cos(2*pi*arg);
        case {'hann','hanning'}
            option.Window=0.50-0.50*cos(2*pi*arg);
        case 'blackman'
            option.Window=0.42-0.50*cos(2*pi*arg)+0.08*cos(4*pi*arg);
        case {'boxcar','rectangle','flat','none'}
            option.Window=ones(size(arg));
        otherwise
            error('ERROR: invalid window name');
    end
elseif iscell(option.Window)
    name=option.Window{1};
    assert(ischar(name),'ERROR: invalid window name');
    switch lower(name)
        case {'gaussian','gauss'}
            L=option.Window{2};
            sigma=(arg(end)-arg(1))/(2*L);
            mid=(arg(end)+arg(1))/2;
            option.Window=exp(-(arg-mid).^2/(2*sigma^2));
        otherwise
            error('ERROR: unknown window name');
    end
end
assert(isnumeric(option.Window),'ERROR: invalid window');
assert(numel(option.Window)==numpoints,...
    'ERROR: window/signal sizes are not consistent')
option.Window=reshape(option.Window,size(signal));

assert(islogical(option.RemoveDC),'ERROR: invalid RemoveDC setting');

value=option.NumberFrequencies;
if ~isnumeric(value) || any(value~=round(value)) || any(value<1)
    error('ERROR: invalid NumberFrequencies setting');
elseif (numel(value)==1) && ~isinf(value)
    option.NumberFrequencies(end+1)=inf;
elseif (numel(value)==2) && (value(2)>=value(2))
    % this is ideal
else
    error('ERROR: invalid NumberFrequencies setting');
end

switch option.SpectrumType
    case {'power','power_dB','complex','phase'}
        % valid choice
    otherwise
        error('ERROR: invalid SpectrumType setting');
end

%% calculate spectrum
T=(time(end)-time(1))/(numpoints-1);
N2A=pow2(nextpow2(numpoints));
N2B=pow2(nextpow2(2*(option.NumberFrequencies(1)-1)));
N2=max(N2A,N2B);
N2=pow2(nextpow2(N2));

if option.RemoveDC
    signal=signal-mean(signal(:));
end
RawSignal=signal;
signal=signal.*option.Window;
signal(N2)=0;

frequency=(-N2/2):(+N2/2-1);
frequency=frequency(:)/(N2*T);
transform=fft(signal,N2);
transform=fftshift(transform);

Delta=(numpoints-1)*T/2;
correction=exp(2i*pi*frequency*Delta);
transform=transform.*correction; % phase correction

switch option.FrequencyDomain
    case 'positive'
        index=(N2/2+1):numel(frequency);
        AreaMultipler=2;
    case 'negative'
        index=1:(N2/2);
        AreaMultipler=2;
    case {'full','all'}
        index=1:N2;
        AreaMultipler=1;
    otherwise
        error('ERROR: invalid FrequencyDomain');
end
frequency=frequency(index);
transform=transform(index);

%% downsample as needed
if numel(frequency)>option.NumberFrequencies(2)
    switch option.FrequencyDomain
        case 'positive'
            f=linspace(0,max(frequency),option.NumberFrequencies(2));
        case 'negative'
            f=linspace(min(frequency),0,option.NumberFrequencies(2));
        otherwise
            f=linspace(min(frequency),max(frequency),2*option.NumberFrequencies(2));
    end
    transform=EAinterp(frequency,transform,f);
    frequency=f;
    downsample=true;
else
    downsample=false;
end

%% return requested spectrum
if strcmpi(option.SpectrumType,'phase')
    phase=atan2(imag(transform),real(transform));
    phase=unwrap(phase,-pi/4);
    transform=phase;
else    
    x=1:numel(RawSignal);
    x=(x-1)*T;
    area1=real(RawSignal).^2+imag(RawSignal).^2;
    area1=trapz(x,area1);
    P=real(transform.*conj(transform));
    area2=AreaMultipler*trapz(frequency,P);
    ratio=area1/area2; % energy ratio
    ratio=ratio/abs(time(end)-time(1));
    P=P*ratio; % average power
    switch option.SpectrumType
        case 'power'
            transform=P;
        case 'power_dB'
            transform=10*log10(P);
        case 'complex'
            transform=transform*sqrt(ratio);
    end
end

%% handle output
if nargout==0
    figure;
    switch option.SpectrumType
        case 'power'
            plot(frequency,transform);
            ylabel('Power');
            label=sprintf('Power spectrum of "%s"',object.Name);
        case 'power_dB'
            plot(frequency,transform);
            ylabel('Power (dB scale)');
            label=sprintf('Power spectrum of "%s"',object.Name);
        case 'complex'
            plot(frequency,real(transform),frequency,imag(transform));
            ylabel('Transform');
            label=sprintf('Fourier transform of "%s"',object.Name);
            legend('Real','Imaginary');
        case 'phase'
            plot(frequency,transform);
            ylabel('Phase (radians)');
            label=sprintf('Phase spectrum of "%s"',object.Name);
    end
    xlabel('Frequency')
    title(label);
elseif nargout==1
    varargout{1}=SMASH.SignalAnalysis.Signal(frequency,transform);
else
    varargout{1}=frequency;
    varargout{2}=transform;
    varargout{3}=option;
    varargout{4}=downsample;
end

end

function y2=EAinterp(x1,y1,x2)

if ~isreal(y1)
    p=EAinterp(x1,real(y1),x2);
    q=EAinterp(x1,imag(y1),x2);
    y2=p+1i*q;
    return
end

area=cumtrapz(x1,y1);

L2=(x2(end)-x2(1))/(numel(x2)-1);
dx=L2/2;
xm=x2-dx;
xm(end+1)=xm(end)+L2;
xm=xm(:);
Am=interp1(x1,area,xm);

slope=(Am(2)-area(1))/dx;
Am(1)=Am(2)-slope*L2;
slope=(area(end)-Am(end-1))/dx;
Am(end)=Am(end-1)+slope*L2;

y2=diff(Am)/L2;

end