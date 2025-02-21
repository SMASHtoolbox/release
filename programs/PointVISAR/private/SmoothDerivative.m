% SmoothDerivative : calculate a smooth derivative using the Savitzky-Golay
% method
% 
% Usage: 
%
% params=[order numpoints]
%
% [dydy,ysmooth]=SmoothDerivative(params,y,x); % standard form
%
% params=SmoothDerivative(params); % verify parameter set
% 
%

% created 1/7/2008 by Daniel Dolan
% updated 1/16/2008 by Daniel Dolan
%   -added matrix scaling to improve condition number
function varargout=SmoothDerivative(params,y,x) 

% allocate missing input variables
if nargin<1
    params=[];
end
if nargin<2
    y=[];
end
if nargin<3
    x=[];
end

% interpret parameters: [deriv order numpoints]
order=[];
numpoints=[];
params=round(abs(params));

Nparams=numel(params);
if Nparams>0
    order=params(1);
end
if Nparams>1
    numpoints=params(2);
end

paramchange=false;
if isempty(order) || order<1
    order=1;
    paramchange=true;
end
if isempty(numpoints) || (numpoints<=order)
    numpoints=order+2;
    paramchange=true;
end
if rem(numpoints,2)==0 % even number of points
    numpoints=numpoints+1; % move to odd number
    paramchange=true;
end
params=[order numpoints];
 
% generate convolution weights
jr=floor((numpoints+1)/2);
w=SGweight(order,numpoints,jr);
if nargin<2 % no data given
    varargout{1}=params;
    varargout{2}=w(1:2,end:-1:1);
    return
end

% notify user of parameter change
if paramchange
    fprintf('Derivative parameters set to [%d %d] for consistency\n',...
        [order numpoints]);
end

% identify boundary points
N=numel(y);
nskip=(numpoints+1)/2;
skip=[1:nskip (N-nskip):N];

% % begin binomial filter testing %
% Np=(numpoints-1)/2;
% b=1;
% for k=2:Np
%     b=conv(b,[1 2 1]/4);
% end
% 
% if isempty(x)
%     dx=1;
% elseif numel(x)==1
%     dx=x;
% else
%     dx=(max(x)-min(x))/(numel(x)-1);
% end
% bd=conv(b,[1 0 -1]/2);
% varargout{1}=conv2(y,bd,'same')/dx;
% varargout{1}(skip)=nan;
% 
% varargout{2}=conv2(y,b,'same');
% varargout{2}(skip)=nan;
% 
% return
% % end binomial filter testing %

% perform convolution
varargout{1}=conv2(y,w(2,end:-1:1),'same'); % smoothed derivative
if isempty(x)
    dx=1;
elseif numel(x)==1
    dx=x;
else
    dx=(max(x)-min(x))/(numel(x)-1);
end
varargout{1}=varargout{1}/dx; % derivative scaling
varargout{1}(skip)=nan;

if nargout>1
    varargout{2}=conv2(y,w(1,end:-1:1),'same'); % smoothed data
    varargout{2}(skip)=nan;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Savitzky-Golay weight generator %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function weight=SGweight(order,numpoints,kr)

if (nargin<3) || isempty(kr)
    kr=ceil(numpoints/2);
end

% [jj,kk]=meshgrid(1:numpoints,1:(order+1));
% L=(jj-jr).^(kk-1);
% R=zeros(order+1,order+1);
% for ii=1:(order+1)
%     temp=(jj-jr).^(ii+kk-2);
%     R(:,ii)=sum(temp,2);
% end
% weight=(R\L).*factorial(kk-1);

N=numpoints;
M=order+1;

[n,k]=ndgrid(1:M,1:N);
L=((k-kr)/N).^(n-1);

R=zeros(order+1,order+1);
k=((1:N)-kr)/N;
for n=1:M
    for m=1:M
        R(n,m)=sum(k.^(n+m-2));
    end
end

%fprintf('rcond(R)=%g\n',rcond(R));
weight=R\L;
for q=0:order
    weight(q+1,:)=weight(q+1,:)*factorial(q)/N^q;
end