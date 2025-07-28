function [dxdt,x]=FTderiv(x,tau,T)

% soft padding
N=numel(x);
x=softpad(x);
N2=numel(x);

% perform FFT
xt=fft(x);
mpos=0:(N2/2);
mneg=(N2/2-1):-1:1;
m=[mpos -mneg];
omega=2*pi*m/(N2*T);

% apply derivative transfer
[H,Z]=DerivativeTransfer(omega,tau);
x=ifft(xt.*Z,N2);
dxdt=ifft(xt.*H,N2);

% elimate padded points
x=real(x(1:N));
dxdt=real(dxdt(1:N));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% derivative transfer function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [H,Z]=DerivativeTransfer(omega,tau)

% generate transfer function
omega1=2*pi/tau(1);
omega2=2*pi/tau(2);
Z=zeros(size(omega));
k=(abs(omega)<omega1);
Z(k)=1;
if omega2>omega1
    k=(abs(omega)>=omega1)&(abs(omega)<=omega2);
    Z(k)=(1+cos(pi*(abs(omega(k))-omega1)/(omega2-omega1)))/2;
end
H=(i*omega).*Z;