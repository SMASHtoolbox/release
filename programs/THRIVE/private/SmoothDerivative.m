% SmoothDerivative : calculate a smooth derivative using the Savitzky-Golay
% method.  The derivative level may be specified by an array of positive
% integers (including zero); the result for each array entry is returned as
% a separate function output. The order and number of points used in the
% calculation are specified by an array param=[order numpoints].  Dependent
% data to be smoothed is specified in a 1D array y.  The distance between
% adjacent samples may be specified by a fourth input, which can be a
% scalar or an evenly spaced array.
%
% Standard usage:
%   >>dydx=SmoothDerivative(1,param,y,x);
%   >>ys=SmoothDerivative(0,param,y,x);
%   >>[ys,dydx]=SmoothDerivative([0 1],param,y,x);
%
% Advanced usage:
%   >>weight=SmoothDeriv(deriv,param); % no data specified
%   When no data is specified, the function returns the convolution weights
%   that would be used for the specied derivative level(s).  
%   >>[dydx,param]=SmoothDerivative(1,param,y,x);
%   The actual parameter set used by the function is always the *last*
%   output value.  The output value may differ from the input if
%   the order and/or number of points are inconsisent with the specified
%   derivatives(s).

% created 1/7/2008 by Daniel Dolan
% updated 1/16/2008 by Daniel Dolan
%   -added matrix scaling to improve condition number
% updated 7/14/2009 by Daniel Dolan
%   -deriv may now be an array, creating multiple function outputs
%   -convolution is automatically oriented for column or row vectors
% updated 8/5/2009 by Daniel Dolan
%   -modified the skip algorithm to prevent dropping too many points
%   -fixed several bugs with input/output handling  
%   -fixed a small bug in which two factorial corrections were applied to
%   derivative calculations
function varargout=SmoothDerivative(deriv,param,y,x) 

% handle input
if (nargin<1) || isempty(deriv)
    deriv=1;
end
deriv=ceil(deriv);
if any(deriv<0)
    error('ERROR: negative derivative specified');
end

if (nargin<2) || isempty(param)
    order=0;
    numpoints=0;
else
    param=ceil(param);    
    order=param(1);
    numpoints=param(2);
end
order=max([order max(deriv)]);
numpoints=max([numpoints order+1]);
if rem(numpoints,2)==0
    numpoints=numpoints+1; % use an odd number of points
end
param=[order numpoints];

% generate convolution weights
jr=floor((numpoints+1)/2);
weight=SGweight(order,numpoints,jr);
weight=weight(deriv+1,end:-1:1);

% determine step size
if nargin<3 % no data given
    varargout{1}=weight;
    varargout{2}=param;
    return
elseif nargin==3
    dx=1;
elseif numel(x)==1
    dx=x;
else
    dx=(x(end)-x(1))/(numel(x)-1);
end

% check signal shape
if size(y,1)==1
    isrow=true;
else
    isrow=false;
end

% identify boundary points
N=numel(y);
nskip=(numpoints-1)/2;
skip=[1:nskip (N+1-nskip):N];

% calculate derivatives
M=numel(deriv);
varargout=cell(1,M+1);
for k=1:M
    if isrow
        kernel=weight(k,:);
    else
        kernel=transpose(weight(k,:));
    end
    varargout{k}=conv2(y,kernel,'same');
    kderiv=deriv(k);
    if kderiv>0
        varargout{k}=varargout{k}/dx^(kderiv);
    end
    varargout{k}(skip)=nan;
end
varargout{end}=param;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Savitzky-Golay weight generator %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [weight,cond_num]=SGweight(order,numpoints,kr)

if (nargin<3) || isempty(kr)
    kr=ceil(numpoints/2);
end

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

cond_num=rcond(R);
weight=R\L;
for q=0:order
    weight(q+1,:)=weight(q+1,:)*factorial(q)/N^q; 
end