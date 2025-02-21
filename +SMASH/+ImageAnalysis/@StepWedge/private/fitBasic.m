function result=fitBasic(x,y,options)

% manage input
if (nargin<3) || isempty(options)
    options=optimset('MaxFunEvals',2000);
end

N=numel(x);
x=x(:);
y=y(:);
[x,index]=sort(x);
y=y(index);

% derivative
x1=[];
dydx_x1=0;
x2=[];
dydx_x2=[];
x3=[];
dydx_x3=[];
x4=[];
dydx_x4=0;
    function dydx=derivative(xd,yd)
        dydx=zeros(size(yd));
        % region 2
        slope=(dydx_x2-dydx_x1)/(x2-x1);
        index=(xd>=x1) & (xd<x2);        
        dydx(index)=dydx_x1+slope*(xd-x1);
        % region 3
        slope=(dydx_x3-dydx_x2)/(x3-x2);
        index=(xd>=x2) & (xd<x3);
        dydx(index)=dydx_x2+slope*(xd-x2);
        % region 4
        slope=(dydx_x4-dydx_x3)/(x4-x3);
        index=(xd>=x3) & (xd<x4);
        dydx(index)=dydx_x3+slope*(xd-x3);
    end

% optimization
matrix=ones(N,2);
fit=[];
    function chi2=residual(param)
        x1=xref+param(1)^2;
        x2=x1+param(2)^2;
        x3=x2+param(3)^2;
        x4=x3+param(4)^2;
        dydx_x2=param(5);
        dydx_x3=param(6);
        [~,temp]=ode45(@derivative,x,0);
        matrix(:,2)=temp;
        vector=matrix\y;
        fit=matrix*vector;
        chi2=(y-fit).^2;
        chi2=mean(chi2)/N;
    end
xref=min(x);
L=max(x)-xref;
a=(max(y)-max(x))/L;
guess=[sqrt(L/5) sqrt(L/5) sqrt(L/5) sqrt(L/5) a a];
result=fminsearch(@residual,guess,options);

plot(x,y,'o',x,fit,'k');

end