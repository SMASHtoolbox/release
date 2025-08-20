% IterativeEllipseFit : iterative ellipse fit with fixed parameter options

% created 12/06/07 by Daniel Dolan

function params=IterativeEllipseFit(D1,D2,D3,guess,fixed,options)

% input check
if nargin<4
    error('At least four inputs are required');
end
if nargin<5
    fixed=[];
end
if nargin<6
    options='';
end

% default input
if isempty(fixed)
    fixed=repmat(false,[1 8]);
end
if isempty(options)
    options=optimset();
end

% construct variable and fixed parameter arrays
fixparam=guess(fixed);
varparam=guess(~fixed);

% optimize variable parameters
varparam=fminsearch(@residual,varparam,options,fixparam,fixed,D1,D2,D3);
[chi2,params]=residual(varparam,fixparam,fixed);

%%%%%%%%%%%%%%%%%%%%%%%%%
% dual ellipse residual %
%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2,param]=residual(varparam,fixparam,fixed,D1,D2,D3)

param=zeros(size(fixed));
kvar=1;
kfix=1;
for k=1:numel(fixed)
    if fixed(k)
        param(k)=fixparam(kfix);
        kfix=kfix+1;
    else
        param(k)=varparam(kvar);
        kvar=kvar+1;
    end
end

x0=param(1);
Ax=param(2);
y0=param(3);
Ay=param(4);
z0=param(5);
Az=param(6);
epsplus=param(7);
epsminus=param(8);

if nargin<4 % return current variable state
    chi2=nan;
    return
end

% enforce parameter bounds
if (Ax<=0) || (Ay<=0) || (Az<=0)
    chi2=inf;
    return
end

% calculate residual error
x=D1-x0;
y=D2-y0;
rho=Ax/Ay;
eta=sin(epsplus);
chi2xy=sum((x.^2+rho^2*y.^2+2*rho*eta*x.*y+(eta^2-1)*Ax^2).^2);

y=D3-z0;
rho=Ax/Az;
eta=sin(epsminus);
chi2xz=sum((x.^2+rho^2*y.^2+2*rho*eta*x.*y+(eta^2-1)*Ax^2).^2);

N=numel(x);
chi2=sqrt(chi2xy+chi2xz)/(2*N);