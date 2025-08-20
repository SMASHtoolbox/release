function data=correctWindow(data)

kernel=@(un) cos(2*pi*10*un).^2;
I1=integral(kernel,-0.5,0.5);
kernel=@(un) data.Function(un).^2.*cos(2*pi*10*un).^2;
I2=integral(kernel,-0.5,+0.5);
data.PowerCorrection=sqrt(I1/I2);

I3=integral(data.Function,-0.5,+0.5);
data.AmplitudeCorrection=1/I2;

I4=integral(@(un) data.Function(un).^2,-0.5,+0.5);
data.BandwidthCorrection=I4/I3^2;

end