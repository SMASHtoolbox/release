function report=erffit(x,y,guess)

% manage input
if isempty(guess)
    guess=[mean(x) (max(x)-min(x))/2];
end

% initial preparations
options=optimset('TolX',1e-6,'TolFun',1e-6);

% normalize data
x0=min(x);
Lx=max(x)-x0;
x=(x-x0)/Lx;

y0=min(y);
Ly=max(y)-y0;
y=(y-y0)/Ly;

guess(1)=(guess(1)-x0)/Lx;
guess(2)=guess(2)/Lx;

% perform nonlinear optimization
fitness=@(NLparams) residual(NLparams,x,y);
[NLparams,~,~]=fminsearch(fitness,guess,options);
[~,params,yfit]=residual(NLparams,x,y);

% convert results to original scale
params(1)=y0+Ly*params(1);
params(2)=Ly*params(2);
params(3)=x0+Lx*params(3);
params(4)=Lx*params(4);
yfit=y0+Ly*yfit;

% generate report
report=struct();
report.Method='erffit';
report.Description='Error function step with constant background';
report.Location=params(3);
report.Width=params(4);
report.Amplitude=params(2);
report.Baseline=params(1);
report.Fit=yfit;
report.Parameters=params;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear least squares residual function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2,params,yfit]=residual(NLparams,x,y)

% extract nonlinear least square parameters
x0=NLparams(1);
Lx=NLparams(2);
if (x0<min(x)) || (x0>max(x))
    chi2=inf;
    return
end
dx=(max(x)-min(x))/(numel(x)-1);
if Lx<dx
    chi2=inf;
    return
end

% determine linear least square parameters
Ndata=numel(x);
M=ones(Ndata,2);
%M(:,2)=exp(-(x-xp).^2/(2*sigma^2));
M(:,2)=(1+erf((x-x0)/Lx))/2;

Lparams=M\y(:);
y0=Lparams(1);
A=Lparams(2);

% combine parameters
params=[y0 A x0 Lx];

% calculate residual error
%yfit=gaussians(params,x);
yfit=y0+A*M(:,2);
chi2=sum((y(:)-yfit).^2);