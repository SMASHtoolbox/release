function varargout=fitSigmoidODE(x,y)

N=numel(x);
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

% sigmoid derivative
xA=[];
LA=[];
xB=[];
LB=[];
gamma=[];
    function dydx=derivative(xd,yd)
        g=zeros(size(yd));
        index=(xd<=xA);
        g(index)=exp(+(xd(index)-xA)/LA);       
        index=(xd>xA) & (xd<=xB);
        g(index)=1;
        arg=(xd(index)-xA)/(xB-xA);
        for k=1:numel(gamma)            
            g(index)=g(index)+gamma(k)*arg.^k;
        end
        index=(xd>xB);
        g(index)=(1+sum(gamma))*exp(-(xd(index)-xB)/LB);
        dydx=g.^2;
    end

% curve fit
fit=[];
vector=[];
matrix=ones(N,2);
options=odeset('RelTol',1e-6);
    function chi2=residual(param)
        xA=param(1);
        LA=(L/10)+param(2)^2;
        xB=param(3);
        LB=(L/100)+param(4)^2;
        gamma=param(5:end);
        [~,matrix(:,2)]=ode45(@derivative,x,0,options);
        vector=matrix\y;
        fit=matrix*vector;
        chi2=(y-fit).^2;
        chi2=mean(chi2)/N;
    end
L=max(x)-min(x);
guess=[min(x)+L/4 0 max(x)-L/4 0];
guess(end+1:end+2)=0;
%guess(end+1:end+4)=0;
result=fminsearch(@residual,guess)

xf=linspace(min(x),max(x),1000);
[~,yf]=ode45(@derivative,xf,0,options);
yf=vector(1)+vector(2)*yf;
plot(x,y,'o',xf,yf);

end