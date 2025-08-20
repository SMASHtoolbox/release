%% original signal
time=-100:(1/2):(2100); % ns
time=time(:);
phi=(32/180)*pi;
f0=0.002; % GHz
original=SMASH.SignalAnalysis.Signal(time,sin(2*pi*f0*time+phi));

%% staggered signals
Delta=[0 -2 13];
A=[0.9 0.8 0.7];
B=[0 0 0];
param=[Delta(:) A(:) B(:)];
bound=[-1.1 -0.4; -0.6 0.6; 0.4 1.1];
%noise=zeros(1,3);
%noise=[0.00 0.02 0.05];
noise=0.05;
data=SMASH.SignalAnalysis.RedundantSignal.generate(original,param,bound,...
    noise);

%% analysis
object=SMASH.SignalAnalysis.RedundantSignal(data);
object.Range=bound;
object=calibrateSinusoid(object,object.Measurement);

object.NoiseRatio=noise;
result=weld(object);
result.GraphicOptions.LineColor='r';
view(original);
view(result,gca);
