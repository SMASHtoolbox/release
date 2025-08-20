% study
function studyNoise(object,blocks)

% make sure there is enough signal
safety=10;
width=2*safety/object.EffectiveTime;
range=object.SampleRate/2;
maxblocks=floor(range/width);
assert(maxblocks > 5,'ERROR: not enough signal for noise study');
if maxblocks < 20
    warning('More signal needed for accurate noise study');
end

% manage input
if (nargin < 2) || isempty(blocks)
    blocks=min(20,maxblocks);
else
    assert(testNumber(blocks),'ERROR: invalid number of analysis blocks');
    if blocks > maxblocks
        warning('Reducing locks blocks from %d to %d due to signal limitations',...
            blocks,maxblocks)
        blocks=maxblocks;
    end
end

%% transform entire signal
N=numel(object.Signal);
t=object.Time;
duration0=abs(t(end)-t(1));
un=(t-mean(t))/duration0;
window=object.Window.Function(un);
data=object.Signal.*window;
area1=trapz(t,data.^2);

N2=pow2(nextpow2(N));
data=fft(data,N2);
k=0:(N2/2);
data=data(k+1);
f=k/N2*object.SampleRate;

data=abs2(data);
area2=trapz(f,data);
scale=area1/area2;
data=data*scale;

% process blocks
start=linspace(0,f(end),blocks+1);
stop=start(2:end);
start=start(1:end-1);
fit=nan(1,blocks);
for n=1:blocks
   index=(f >= start(n)) & (f <= stop(n));
   fit(n)=median(data(index))/log(2);
end
center=(start+stop)/2;

xi=[0 center f(end)];
yi=interp1(center,fit,xi,'nearest','extrap');

% compare time/frequency integrals
area2=trapz(xi,yi);
area1=trapz(t,window.^2);
noise=sqrt(area2/area1);

% manage output
if nargout == 0
    figure();
    plot(f,data,'r',xi,yi,'k');
    set(gca,'YScale','log');
    xlabel('Frequency');
    ylabel('Energy density');
    legend('Total','Noise');
    title(sprintf('Noise floor = %#.2g',noise));
    return
end

varargout{1}=noise;
varargout{2}=maxblocks;

end