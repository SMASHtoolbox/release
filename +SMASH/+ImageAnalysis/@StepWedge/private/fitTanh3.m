function result=fitTanh3(x,y,order,options)

% manage input
if (nargin<3) || isempty(order)
    order=2;
end

if (nargin<4) || isempty(options)
    options=optimset('MaxFunEvals',2000);
end

N=numel(x);
x=x(:);
y=y(:);
[x,k]=sort(x);
y=y(k);

% define derivative
x0=[];
L=[];
LA=[];
LB=[];
gamma=[];
    function dydx=derivative(xd,~)
        %index=
%         %dydx=zeros(size(yd));
%         xnorm=(xd-x0)/L;
%         dydx=polyval(gamma,xnorm).^2;
%         %dydx=polyval(gamma,xd).^2.*exp(abs(xd));
%         index=(xd<=x0);       
%         xnorm=(xd(index)-x0)/LA;
%         dydx(index)=dydx(index).*exp(abs(xnorm));
%         index=(xd>x0);
%         xnorm=(xd(index)-x0)/LB;
%         dydx(index)=dydx(index).*exp(abs(xnorm));
    end

% perform fit
matrix=ones(N,2);
vector=[];
fit=[];
    function chi2=residual(param)
        x0=param(1);
        L=param(2);   
        LA=param(3);
        LB=param(4);
        gamma=param(end:-1:5);
        gamma(end+1)=1;
        arg=zeros(N,1);
        index=(x>=x0); 
        xi=[x0; x(index)];           
        [xi,yi]=ode45(@derivative,xi,0);        
        arg(index)=interp1(xi,yi,x(index),'nearest');
        index=(x<=x0);
        xi=x(index);
        xi=xi(end:-1:1);
        xi=[x0; xi];
        [xi,yi]=ode45(@derivative,xi,0);
        arg(index)=interp1(xi,yi,x(index),'nearest');
        matrix(:,2)=tanh(arg);
        vector=matrix\y;
        fit=matrix*vector;
        chi2=(y-fit).^2;
        chi2=sum(chi2)/N;
    end
xmin=min(x);
xmax=max(x);
Lx=xmax-xmin;
xmean=(xmin+xmax)/2;
guess=[xmean Lx/4 Lx/8 Lx/8];
guess(end+1:end+order)=0;

result=fminsearch(@residual,guess,options);
final=sqrt(residual(result));
fprintf('Average error: %.2g\n',final);

%%
%subplot(2,1,1);
plot(x,y,'o',x,fit,'k');
xlabel('x=log_{10} (exposure)');
ylabel('Step density');

end