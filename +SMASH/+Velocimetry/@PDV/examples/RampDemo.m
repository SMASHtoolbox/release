%% create artificial PDV signal
fs=40e9; % sample rate
t=-50e-9:(1/fs):100e-9; % time base

fc=[2e9 4e9];
tc=[0 60e-9];
f=repmat(fc(1),size(t));
k=(t > tc(1));
f(k) = fc(1)+diff(fc)*(t(k)-tc(1))/diff(tc);
f(t > tc(2))=fc(2);

temp=SMASH.SignalAnalysis.Signal(t,f);
temp=2*pi*integrate(temp)+2*pi*rand(1); % phase
temp=reset(temp,[],cos(temp.Data));

noise=SMASH.SignalAnalysis.NoiseSignal(t);
noise.Amplitude=0.10;
noise=defineTransfer(noise,'bandwidth',8e9);
noise=generate(noise);

temp=temp+noise.Measurement;

%% create PDV object
object=SMASH.Velocimetry.PDV(temp);
view(object);
disp(object.Partition)

view(object,'signal');

%% make refined spectrogram
object=partition(object,'Duration',[5e-9 1e-9]);
object=generateSpectrogram(object);
view(object);

%% define reference region
object=selectReference(object,[-inf -1e-9]);

%% determine offset frequency
object=calculateOffset(object);
view(object);

%% calculate velocity
object=generateHistory(object);
view(object,'history');
view(object,'overlay');

%% scale and shift time
new=scaleTime(object,1e9); % seconds become nanoseconds
new=shiftTime(new,25);
view(new,'history');
