
%% generate signal
time=linspace(0,1,10e3);
signal=cos(2*pi*4*time+2*pi*rand(1));
signal=signal+0.10*randn(size(time));
object=SMASH.SignalAnalysis.Signal(time,signal);

view(object);

%%
[range,uncertainty]=estimateRange(object,0.02)