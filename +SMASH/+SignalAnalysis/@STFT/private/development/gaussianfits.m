% gaussianfits : fit data to Gaussian curves
%
% Usage:
%   >> [params,yfit]=gaussianfit(x,y,guess,options);
%function [params,yfit]=gaussianfits(x,y,Npeaks,guess,options)
function [param,fit]=gaussianfits(x,y,varargin)

% handle input
assert(nargin>=2,'ERROR: insufficient number of inputs');
assert(numel(x)==numel(y),'ERROR: inconsistent data arrays');

Narg=numel(varargin);
assert(rem(Narg,2),'ERROR: unmatched name/value pair');
peaks=1;
guess=[];
separation=(max(x)-min(x))/(numel(x)-1);
options=optimset('TolX',1e-6,'TolFun',1e-6);
for n=1:2:Narg
    name=varargin{n};
    value=varargin{n+1};
    switch name
        case 'guess'
            guess=value;
        case 'options'
            options=value;
        case 'separation'
            separation=value;
        case 'peaks'
            peaks=value;
        otherwise
            error('ERROR: invalid name');
    end
end

if isempty(guess)
    [~,index]=max(y);
    xp=x(index);   
    xtemp=reshape(x-xp,size(y));
    sigma=sqrt(sum(y.*xtemp.^2)/sum(y));
    guess=[xp sigma];
    guess=repmat(guess,[1 Npeaks]);
end

% error checking
assert(isnumeric(peaks) && isscalar(peaks),...
    'ERROR: invalid number of peaks');
peaks=round(peaks);
assert(peaks>=1,'ERROR: invalid number of peaks');

assert(numel(guess)==(2*peaks),'ERROR: invalid guess')

assert(isnumeric(separation) && isscalar(separation),...
    'ERROR: invalid number of separation');
separation=round(separation);
assert(separation>=1,'ERROR: invalid separation');

% scale data
x=x(:);
y=y(:);
numpoints=numel(x);

x0=min(x);
Lx=max(x)-x0;
x=(x-x0)/Lx;

y0=min(y);
Ly=max(y)-y0;
y=(y-y0)/Ly;

guess(1:2:end)=(guess(1:2:end)-x0)/Lx;
guess(2:2:end)=guess(2:2:end)/Lx;

% TRANSITION TO FIXED WIDTHS?

% perform nonlinear optimization
    function [chi2,param,fit]=residual(NLparam)
        xp=NLparam(1:2:end);
        sigma=NLparam(2:2:end);
        matrix=nan(numpoints,peaks);
        reference=1:peaks;
        for m=1:peaks
            if (m==1) || all(abs(xp(m)-xp(1:m-1)))
                matrix(:,m)=exp(-(x-xp(m)).^2/2/sigma(m)^2);
            else
                reference=find(~isnan(matrix(1,1:m-1),1,'last'));
            end            
        end
        keep=~isnan(matrix(1,:));
        matrix=matrix(:,keep);
        
    end
fitness=@(NLparams) residual(NLparams,x,y);
[NLparams,fval]=fminsearch(fitness,guess,options);
[chi2,params,yfit]=residual(NLparams,x,y);

% convert results to original scale
params(1)=y0+Ly*params(1);
params(2)=Ly*params(2);
params(3)=x0+Lx*params(3);
params(4)=Lx*params(4);
yfit=y0+Ly*yfit;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% nonlinear least squares residual function %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [chi2,params,yfit]=residual_old(NLparams,x,y)

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

end