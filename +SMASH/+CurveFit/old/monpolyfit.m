% 
function param=monpolyfit(x,y,order)

assert(nargin >= 3,'ERROR: insufficient input');
assert(isnumeric(x) && isnumeric(y),'ERROR: invalid (x,y) data');
N=numel(x);
assert(numel(y) == N,'ERROR: inconsistent (x,y) data');
x0=min(x);
x=x(:)-x0;
y0=min(y);
y=y(:)-y0;

valid=2:(N-1);
assert(any(order == valid),'ERROR: fit order must be an integer >= 2');


import SMASH.CurveFit.monpoly
matrix=ones(N,2);
offset=nan;
scale=nan;
fit=nan;
    function chi2=residual(local)
        local=[1 local];
        B=polyint(conv(local,local));
        B=B/B(1);        
        matrix(:,2)=polyval(B,x);
        q=matrix\y;
        offset=q(1);
        scale=q(2);
        fit=matrix*q;
        chi2=mean((y-fit).^2);
    end
guess=zeros(1,order-1);
result=fminsearch(@residual,guess);
result=[1 result];
param=scale*polyint(conv(result,result));
param(end)=param(end)+offset;

fit2=polyval(param,x);

end