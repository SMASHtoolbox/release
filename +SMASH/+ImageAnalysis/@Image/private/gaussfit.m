% gaussfit
function report=gaussfit(x1,x2,y,guess,bound)

% manage input
if isempty(guess)
    [temp,index1]=max(abs(y));
    [~,index2]=max(temp);
    x1p=x1(index2);
    x2p=x2(index1(index2));
    %xtemp=reshape(x-xp,size(y));
    %sigma=sqrt(sum(y.*(xtemp-xp).^2)/sum(y));
%     sigma1=(max(x1)-min(x1))/4;
%     sigma2=(max(x2)-min(x2))/4;
    sigma1= min([(max(x1)-x1p)/4 (x1p-min(x1))/4]); % Improves fit finding if point is off-center.
    sigma2= min([(max(x2)-x2p)/4 (x2p-min(x2))/4]);
    guess=[x1p x2p sigma1 sigma2];
end

% inital preprations
options=optimset('TolX',1e-6,'TolFun',1e-6);

% normalize data
x10=min(x1);
Lx1=max(x1)-x10;
x1=(x1-x10)/Lx1;

x20=min(x2);
Lx2=max(x2)-x20;
x2=(x2-x20)/Lx2;

y0=min(min(y));
Ly=max(max(y))-y0;
y=(y-y0)/Ly;

guess(1)=(guess(1)-x10)/Lx1;
guess(3)=guess(3)/Lx1;
guess(2)=(guess(2)-x20)/Lx2;
guess(4)=guess(4)/Lx2;

% perform nonlinear optimization
fitness=@(NLparams) residual(NLparams,x1,x2,y);
[NLparams,~,~]=fminsearch(fitness,guess,options);
[chi2,params,yfit]=residual(NLparams,x1,x2,y);

% convert results to original scale
params(1)=y0+Ly*params(1);
params(2)=Ly*params(2);
params(3)=x10+Lx1*params(3);
params(5)=Lx1*params(5);
params(4)=x20+Lx2*params(4);
params(6)=Lx2*params(6);
yfit=y0+Ly*yfit;

% generate report
report=struct();
report.Method='gaussfit';
report.Description='Single Gaussian peak with fixed background';
report.Location=[params(3) params(4)];
report.Width=[params(5) params(6)];
report.Amplitude=params(2);
report.Baseline=params(1);
report.Fit=yfit;
report.Parameters=params;
report.Chi2=chi2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear least squares residual function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2,params,yfit]=residual(NLparams,x1,x2,y)

% extract nonlinear least square parameters
x1p=NLparams(1);
sigma1=NLparams(3);
x2p=NLparams(2);
sigma2=NLparams(4);
if (x1p<min(x1)) || (x1p>max(x1) || x2p<min(x2)) || (x2p>max(x2))
    chi2=inf;
    return
end
dx1=(max(x1)-min(x1))/(numel(x1)-1);
dx2=(max(x2)-min(x2))/(numel(x2)-1);
if (sigma1<dx1 || sigma2<dx2)
    chi2=inf;
    return
end

% determine linear least square parameters

guess2=[.1,.5]; % Is this actually reasonable? Does it need something more dynamic?

fitness2=@(NLparams2) residual2(NLparams2,x1,x2,y,x1p,x2p,sigma1,sigma2);
[NLparams2,~]=fminsearch(fitness2,guess2);
[chi2,yfit]=residual2(NLparams2,x1,x2,y,x1p,x2p,sigma1,sigma2);

y0=NLparams2(1);
A=NLparams2(2);

% combine parameters
params=[y0 A x1p x2p sigma1 sigma2];



function [chi2,yfit]=residual2(NLparams2,x1,x2,y,x1p,x2p,sigma1,sigma2)

% extract nonlinear least square parameters
y0=NLparams2(1);
A=NLparams2(2);

% create model
M=zeros(numel(x2),numel(x1));
for n=1:numel(x1)
   M(:,n)= exp(-((x2-x2p).^2)/(2*sigma2^2))*exp(-((x1(n)-x1p).^2)/(2*sigma1^2));
end

chi2=sum(sum((y-M).^2));


% calculate residual error
yfit=y0+A*M;
% chi2=sum((y(:)-yfit).^2);
