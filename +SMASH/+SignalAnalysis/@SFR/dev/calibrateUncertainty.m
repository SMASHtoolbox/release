function scale=calibrateUncertainty(object,iterations)

% manage input
if (nargin < 2) || isempty(iterations)
    iterations=200;
end

% analytic value
SNR=10;
limit=sqrt(6/object.SampleRate/object.EffectiveTime^3)/SNR/pi;

% numeric evaluation
stop=object.FullPoints+(iterations-1)*object.StepPoints;
time=(0:stop-1)/object.SampleRate;

f0=object.SampleRate/4;
signal=cos(2*pi*f0*time+2*pi*rand(1));
noise=randn(size(time))/SNR;
signal=signal+noise;

source=packtools.call('SFR',time,signal);
source.RiseTime=object.RiseTime;
source.Noise=1/SNR;
reduce(source,'UncertaintyLimit',20*limit,'MaxPeaks',1);

Delta=source.LastReduction(:,2)-f0;
width=SMASH.Statistics.quantile(Delta,[0.25 0.75]);
width=diff(width);
scale=width/limit;

histogram(Delta);

end