% gaussianfit : fit data to Gaussian curve
%
% Usage:
%   >> [params,yfit]=gaussianfit(x,y,guess,options);
function [params,yfit]=gaussianfit(x,y,guess,options)

% handle mandatory input
if nargin<2
    error('Insufficient number of inputs');
end
Ndata=numel(x);
if numel(x) ~= Ndata
    error('Inconsistent sized data arrays');
end

% scale x- and y-axis
x0=min(x);
Lx=max(x)-x0;
x=(x-x0)/Lx;

y0=min(y);
Ly=max(y)-y0;
y=(y-y0)/Ly;

% handle optional inputs
if (nargin<4) || isempty(guess)
    [junk,index]=max(y);
    xp=x(index);
    xtemp=reshape(x-xp,size(y));
    sigma=sqrt(sum(y.*xtemp.^2)/sum(y));
    guess=[xp sigma];
else
    guess(1)=guess(1)-x0;
    guess=guess/Lx;
end

if (nargin<5) || isempty(options)
    options=optimset('TolX',1e-6,'TolFun',1e-6);
end

% perform nonlinear optimization
fitness=@(NLparams) residual(NLparams,x,y);
[NLparams,fval]=fminsearch(fitness,guess,options);
[chi2,params,yfit]=residual(NLparams,x,y);

% convert results to original scale
params(1)=y0+Ly*params(1);
params(2)=Ly*params(2);
params(3)=x0+Lx*params(3);
params(4)=Lx*params(4);
yfit=y0+Ly*yfit;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear least squares residual function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2,params,yfit]=residual(NLparams,x,y)

% extract nonlinear least square parameters
if any(isnan(NLparams))
    chi2=inf;
    return;
end
xp=NLparams(1);
sigma=NLparams(2);
if (xp<x(1)) || (xp>x(end))
    chi2=inf;
    return
end

% determine linear least square parameters
Ndata=numel(x);
M=ones(Ndata,2);
M(:,2)=exp(-(x-xp).^2/(2*sigma^2));

Lparams=M\y(:);
y0=Lparams(1);
A=Lparams(2);

% combine parameters
params=[y0 A xp sigma];

% calculate residual error
yfit=y0+A*M(:,2);
chi2=sum((y(:)-yfit).^2);