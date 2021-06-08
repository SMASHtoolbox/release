% hidden method
%
% time and frequency are normalized!
function [time,window,frequency,transform]=evaluateWindow(object)

time=linspace(-0.5,+0.5,object.FullPoints);
time=time(:);
window=object.Window.Function(time);

N2=object.TransformPoints;
[frequency,~,transform]=object.calculateFFT(window,N2,'all');

X=real(transform);
temp=SMASH.SignalAnalysis.Signal(frequency,X);
temp=hilbert(temp);
Y=imag(temp.Data);
Y=Y*sqrt(trapz(frequency,X.^2)/trapz(frequency,Y.^2));
transform=X+1i*Y;

end