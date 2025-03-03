% setTimeScale Set FFT time scale(s)
%
% This method sets the time scale(s) used in FFT analysis.  For
% consistency, the total FFT duration is defined in terms of the 10-90%
% rise time.
%    setTimeScale(object,rise);
% The input "rise", combined with the window shape and sample rate, leads
% to an integer number of samples for each FFT. Passing an additional
% input:
%    setTimeScale(object,rise,step);
% controls the time step between FFT calculations.  This value is
% automatically rounded up to match be an integer number of samples.  Empty
% values:
%    setTimeScale(object,[],step);
%    setTimeScale(object,rise,[]);
% indicate values to be left unchanged.
%
% Calling this method updates the *protected* RiseTime, StepTime, and
% TotalStep properties.  Requesting an output:
%    report=setTimeScale(object,rise,step);
% returns a structure with the current settings and additional information
% (rise time bounds, rise/step points, etc.).
%
% See also SFR, setWindow
% 
function varargout=setTimeScale(object,rise,step)

report.SampleRate=object.SampleRate;

% time limits
excess=4; % max peak width relative to Nyquist limit
tau=excess*(2/object.SampleRate);
report.RiseBound(1)=2*object.Window.RiseTime*tau;

time=object.Time;
beta=object.Window.RiseTime;
total=abs(time(end)-time(1));
report.RiseBound(2)=2*beta*total;

report.StepBound(2)=+inf;
T=total/(numel(time)-1);
report.StepBound(1)=T;

% manage duration
if (nargin < 2) || isempty(rise)   
    rise=object.RiseTime;
    if isempty(rise)
        rise=sqrt(prod(report.RiseBound));
    end
else
    assert(SMASH.General.testNumber(rise,'positive','notzero'),...
        'ERROR: invalid rise time');
    if rise < report.RiseBound(1)
        rise=report.RiseBound(1);
        warning('Rise time increased to measurement limit (%g)',rise);
    elseif rise > report.RiseBound(2)
        rise=report.RiseBound(2);
        warning('Rise time decreased to measurement limit (%g)',rise);
    end
end

duration=rise/object.Window.RiseTime;
N=ceil(object.SampleRate*duration);
if rem(N,2) == 1
    N=N+1; % enforce even steps, odd points
end
duration=N*T;
report.DurationTime=duration;
report.DurationPoints=N+1;

rise=duration*object.Window.RiseTime;
report.RiseTime=rise;

% manage step
if (nargin < 3) || isempty(step)
    step=object.StepTime;
    if isempty(step)
        step=max(rise/2,T);
    end
else
    assert(SMASH.General.testNumber(rise,'positive','notzero'),...
        'ERROR: invalid step time');
    if step < T
        step=T;
        warning('Step time increased to measurement limit (%g)',step);   
    end    
end

N=ceil(step/T);
report.StepPoints=N;
step=N*T;
report.StepTime=step;

if step > rise
    message{1}='Step time is *usually* smaller than the rise';
    message{2}='Proceed with caution';
    warning('SFP:LargeStep','%s\n',message{:});
end

right=object.StartTime+report.DurationTime/2;
right=right:step:time(end);
object.TotalSteps=numel(right);
report.TotalSteps=object.TotalSteps;

%
% finish up and manage output
object.RiseTime=rise;
object.StepTime=step;
object.PrivateAmplitude=[];

if nargout < 1
    return
end

varargout{1}=orderfields(report);
if nargout < 2 
    return
end

%% advanced use
parameter=report;

% spectrum scaling
parameter.PeakPoints=object.PeakPoints;
N2=parameter.DurationPoints*object.PeakPoints/2; % boxcar requirement
N2=N2*object.Window.RiseTime*sqrt(3);  % shape correction
N2=pow2(nextpow2(N2));
parameter.TransformPoints=N2;

time=linspace(-0.5,+0.5,parameter.DurationPoints);
time=time(:);
parameter.Window=object.Window.Function(time);

parameter.NormalizedBand=object.FrequencyBand/object.SampleRate;
[fn,~,transform]=object.calculateFFT(parameter.Window,N2,'all');
X=real(transform);
temp=SMASH.SignalAnalysis.Signal(fn,X);
temp=hilbert(temp);
Y=imag(temp.Data);
Y=Y*sqrt(trapz(fn,X.^2)/trapz(fn,Y.^2));
X=griddedInterpolant(fn,X,'pchip','nearest');
parameter.WindowTransform=X;
Y=griddedInterpolant(fn,Y,'pchip','nearest');
parameter.ConjugateTransform=Y;
num=integral(@(u) u.^2.*X(u).^2,0,0.5);
denom=integral(@(u) X(u).^2,0,0.5);
parameter.PeakWidth=sqrt(num/denom)*parameter.SampleRate;
parameter.DistinctPeaks=round(1/sqrt(num/denom));

parameter.TransformFcn=@(x) object.calculateFFT(x,N2,'positive');
f0=0.25;
s=cos(2*pi*f0*parameter.DurationPoints*time).*parameter.Window;
area1=trapz(time,s.^2)/2; % use half area to match f >= 0 integral
s(N2)=0;
[fn,power]=parameter.TransformFcn(s);
parameter.NormalizedFrequency=fn;
area2=trapz(fn,power);
parameter.PowerScaling=area1/area2;

parameter.RMS=object.Noise.RMS;
w2=@(u) object.Window.Function(u).^2;
scale=parameter.RMS^2*integral(w2,-0.5,+0.5)/2;
parameter.NoiseSpectrum=scale*object.Noise.ShapeFcn(fn);

parameter.UncertaintyScaling=parameter.RMS*object.Window.Uncertainty...
    /sqrt(parameter.SampleRate*parameter.DurationTime^3);

varargout{2}=orderfields(parameter);

end