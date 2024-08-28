% private method
function parameter=generateParameter(object,option)

parameter=option;

parameter.SampleRate=object.SampleRate;
parameter.RiseTime=object.RiseTime;
parameter.FullPoints=object.FullPoints;
parameter.StepPoints=object.StepPoints;
parameter.PeakPoints=object.PeakPoints;

N2=calculateTransformPoints(object);

parameter.TransformPoints=N2;
parameter.NormalizedBand=object.FrequencyBand/object.SampleRate;
fn=(0:N2/2)/N2;
parameter.NormalizedFrequency=fn(:);
parameter.TransformPoints=N2;

[time,parameter.Window,frequency,transform]=...
    evaluateWindow(object);
height=abs(interp1(frequency,transform,0));
transform=transform/height;
parameter.WindowTransform=griddedInterpolant(frequency,real(transform),...
    'linear','nearest');
parameter.ConjugateTransform=griddedInterpolant(frequency,imag(transform),...
    'linear','nearest');
Q=@(u) parameter.WindowTransform(u).^2-0.50*parameter.WindowTransform(0).^2;
parameter.FWHM=2*fzero(Q,[0 0.5]);

fn0=0.25;
intervals=object.FullPoints-1;
signal=cos(2*pi*fn0*intervals*time).*parameter.Window;
[fn,power,transform]=object.calculateFFT(signal,N2,'positive');
parameter.AmplitudeScaling=1/abs(interp1(fn,transform,fn0));
parameter.PowerScaling=1/trapz(fn,power);

parameter.RMS=object.Noise.RMS;
w2=@(u) object.Window.Function(u).^2;
scale=parameter.RMS^2*integral(w2,-0.5,+0.5)/2;
parameter.NoiseSpectrum=scale*object.Noise.ShapeFcn(fn);

width=1/object.FullTime;
band=object.FrequencyBand;
parameter.NormalizedThreshold=log(2*(band(2)-band(1))/(width*option.JunkRate));

M=(object.FullPoints-1)/2;
k=-M:M;
tn=linspace(-0.5,+0.5,object.FullPoints);
w=object.Window.Function(tn);
Q=sum(k.^2.*w.^2);
parameter.NormalizedUncertaintyScaling=1/(pi*sqrt(2*Q));

parameter.TransformFcn=@(x) object.calculateFFT(x,N2);

if isfield(option,'MaxOverlap')
    fn=linspace(-1,+1,10e3);
    parameter.NormalizedSeparation=fzero(...
        @(u) calculateOverlap(u)-option.MaxOverlap,[0 0.5]);
end
    function value=calculateOverlap(shift)
        A=parameter.WindowTransform(fn);
        B=parameter.WindowTransform(fn-shift);
        value=etrapz(A.*B,[-1 1])/(etrapz(A.^2,[-1 1]));
    end

parameter.Selection=object.Selection;
N=numel(object.Selection);
for n=1:N
    data=parameter.Selection(n).Data;
    data(:,2:3)=data(:,2:3)/object.SampleRate; % normalization    
    parameter.Selection(n)=define(parameter.Selection(n),data);
end

nhood=ceil(parameter.FWHM*N2);
parameter.IdentifyFcn=...
    @(x) object.identifyContent(x,nhood,parameter.NormalizedThreshold);

parameter=orderfields(parameter);

end