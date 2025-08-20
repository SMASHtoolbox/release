function [Dx,Dy,fringe,variation]=QuadratureReduction(D1,D2,D3,...
    baseline,amplitude,ratio,beta)

% normalized signals
D1=(D1-baseline(1))/amplitude(1);
D2=(D2-baseline(2))/amplitude(2);
D3=(D3-baseline(3))/amplitude(3);

% sum weights
g=zeros(1,3);
g(1)=ratio(1)*cos(beta(1))-ratio(2)*cos(beta(2));
g(2)=ratio(1)*(-1+ratio(2)*cos(beta(2)));
g(3)=ratio(2)*(+1-ratio(1)*cos(beta(1)));

h=zeros(1,3);
h(1)=ratio(1)*sin(beta(1))+ratio(2)*sin(beta(2));
h(2)=-ratio(1)*ratio(2)*sin(beta(2));
h(3)=-ratio(1)*ratio(2)*sin(beta(1));

% calculate quadrature signals
Dy=g(1)*D1+g(2)*D2+g(3)*D3;
Dx=h(1)*D1+h(2)*D2+h(3)*D3;

Phi=unwrap(atan2(Dy,Dx));
index=find(~isnan(Phi),1);
Phi0=Phi(index);
fringe=(Phi-Phi0)/(2*pi);

A1=(D1-ratio(1)*D2)./(cos(Phi)-ratio(1)*cos(Phi+beta(1)));
A2=(D1-ratio(2)*D3)./(cos(Phi)-ratio(2)*cos(Phi-beta(2)));
variation=(A1+A2)/2;
variation=variation.^2;