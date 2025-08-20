% estimate_noise : estimate Gaussian noise fraction in a harmonic signal
%
% Usage:
% >> value=estimate_noise(signal);

% created 9/21/2010 by Daniel Dolan
% completely revised 11/19/2010 by Daniel Dolan
% finalized 11/23/2010 by Daniel Dolan
function value=estimate_noise(signal)

% handle input
if (nargin<1) || isempty(signal)
    time=linspace(0,1,1024);
    signal=cos(2*pi*100*time+2*pi*rand(1))+0.10*randn(size(time));
end

% calculate power spectrum
options=struct('Nduration',1,'window','hann','removeDC',true,'Nfreq',1e4);
[power,tout,frequency,options]=stft(signal,[],options);
power=mean(power,2);

temp=findpeak(frequency,power);
f0=temp(1);
df=temp(2);
peak=(abs(frequency-f0)<5*df);
Npoints=sum(~peak);
if Npoints==0 % peak is wider than spectral window!    
    value=nan;
    return
end

area=trapz(frequency,power);
baseline(1)=mean(power(~peak));
baseline(2)=median(power(~peak));
M=numel(baseline);
value=zeros(M,1);
for k=1:M
    area2=baseline(k)*(frequency(end)-frequency(1));
    area1=area-area2;
    value(k)=sqrt(area2/area1/2);
end

end