% gaussianfit : fit data to Gaussian curve
%
% Usage:
%   >> [params,yfit]=gaussianfit(x,y,guess,options);
function [params,yfit,Dxp]=gaussianfit(x,y,guess,options)

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
if (nargin<3) || isempty(guess)
    [junk,index]=max(y);
    xp=x(index);
    xtemp=reshape(x-xp,size(y));
    sigma=sqrt(sum(y.*xtemp.^2)/sum(y));
    guess=[xp sigma];
else
    guess(1)=guess(1)-x0;
    guess=guess/Lx;
end

%if (nargin<3) || isempty(Niter)
%    Niter=100;
%end

if (nargin<4) || isempty(options)
    options=optimset('TolX',1e-6);
end

% estimate iteration parameters
%baseline=y(1)+(y(end)-y(1))*(x-x(1))/(x(end)-x(1));
%p=(y-baseline).^2;
%p=p/trapz(p);
%xp=trapz(x.*p);
%xp2=trapz(x.^2.*p);
%sigma=sqrt(xp2-xp^2);

% perform nonlinear optimization
fitness=@(NLparams) residual(NLparams,x,y);
[NLparams,fval]=fminsearch(fitness,guess,options);
if isinf(fval)
    keyboard;
end
[chi2,params,yfit]=residual(NLparams,x,y);

% % estimate peak location error (boot strap method)
% if nargout>=3
%     range=3*params(4); % one standard deviation
%     left=params(3)-range;
%     right=params(3)+range;
%     keep=(x>left) & (x<right);
%     Nkeep=sum(keep);
%     xkeep=x(keep);
%     ykeep=y(keep);
%     %s=sqrt(chi2/(Ndata-4)); % four fit parameters
%     xp=params(3);
%     sigma=params(4);
%     xpMC=zeros(1,Niter);
%     for k=1:Niter
%         index=randi([1 Nkeep],size(ykeep));
%         xtemp=xkeep(index);
%         ytemp=ykeep(index);      
%         fitness=@(NLparams) residual(NLparams,xtemp,ytemp);
%         %yk=y(keep)+s*randn(size(y(keep)));
%         %fitness=@(NLparams) residual(NLparams,x(keep),yk);
%         NLparams=fminsearch(fitness,[xp sigma],options);
%         xpMC(k)=NLparams(1);
%     end
%     Dxp=std(xpMC);
% end

% convert results to original scale
params(1)=y0+Ly*params(1);
params(2)=Ly*params(2);
params(3)=x0+Lx*params(3);
params(4)=Lx*params(4);
yfit=y0+Ly*yfit;

%if nargout>=3
%    Dxp=Lx*Dxp;
%end

% % error estimation
% sigma=params(end);
% xp=params(end-1)+[-0.10 0 +0.10]*sigma;
% chi2=zeros(1,3);
% for k=1:3
%     NLparams=[xp(k) sigma];
%     chi2(k)=residual(NLparams,x,y);
% end
% p=polyfit((xp-xp(2))/sigma,chi2-chi2(2),2);
% Dxp=sigma*sqrt(chi2(2)/p(1));
% %if nargout<2
% %    fprintf('Peak location uncertainty: %g\n',Dxp);
% %end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear least squares residual function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2,params,yfit]=residual(NLparams,x,y)

% extract nonlinear least square parameters
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
%yfit=gaussians(params,x);
yfit=y0+A*M(:,2);
chi2=sum((y(:)-yfit).^2);