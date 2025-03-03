% fitGaussian : fit Gaussian curve to (x,y) data
%
% This function fits a Gaussian curve to (x,y) data.
%    >> [param,fit]=itGaussian(x,y,guess,options)
% The inputs "guess" and "options" are optional.  If used, "guess"
% should be a 1x2 array specifiying peak position and width.  The "options"
% input is used to control the optimizer and should be generated with
% MATLAB's optimset function.
%
% See also CurveFit, analyzePeak, optimset
%

%
% created November 21, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function [params,yfit]=fitGaussian(x,y,guess,options)

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
    [~,index]=max(y);
    xp=x(index);
    xtemp=reshape(x-xp,size(y));
    sigma=sqrt(sum(y.*xtemp.^2)/sum(y));
    guess=[xp sigma];
else
    guess(1)=guess(1)-x0;
    guess=guess/Lx;
end

if (nargin<4) || isempty(options)
    options=optimset('TolX',1e-6,'TolFun',1e-6);
end

% perform nonlinear optimization
fitness=@(NLparams) residual(NLparams,x,y);
warning('off','MATLAB:rankDeficientMatrix');
[NLparams,fval]=fminsearch(fitness,guess,options); %#ok<NASGU>
warning('on','MATLAB:rankDeficientMatrix');
[~,params,yfit]=residual(NLparams,x,y);

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