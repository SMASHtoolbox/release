% softpad : signal padding with soft transitions to zero
%
% Given a 1D array, this function returns a zero padded array with a soft
% boundary transitions.  The transition extends over a specified fraction (5% by
% default) of the input array size.  The output array size is smallest power of
% two sufficient to contain the array and left/right padding. The user may also
% specify the number of output elements.  Note that the DC component is removed
% prior to padding.
%
% Usage:
% >> x=softpad(x);
% >> x=softpad(x,fraction);
% >> x=softpad(x,fraction,N);

% created 12/5/2007 by Daniel Dolan

function xpad=softpad(x,fraction,N2)

% allocate missing input
if nargin<2
    fraction=[];
end
if nargin<3
    N2=[];
end

% default input
if isempty(fraction)
    fraction=0.05;
end

% minimum output size
N=numel(x);
Nsoft=round(N*fraction);
N2min=pow2(nextpow2(N+2*Nsoft));
if isempty(N2)
    N2=N2min;
elseif N2<N2min
    fprintf('Insufficient padded array size specified: using N2=%d\n',N2min);
    N2=N2min;
end

% array preparations
k=1:N;
xmean=mean(x);
x=x-xmean;
x=reshape(x,[1 N]);

% right side padding
slope=x(end)-x(end-1);
kr=k(end)+(1:Nsoft);
window=(1+cos(pi*(kr-kr(1))/(kr(end)-kr(1))))/2;
xr=(x(end)+slope*(kr-k(end))).*window;

% left side padding
slope=x(2)-x(1);
kl=k(1)-(1:Nsoft);
window=(1+cos(pi*(kl-kl(1))/(kl(end)-kl(1))))/2;
xl=(x(1)+slope*(kl-k(1))).*window;

Nzero=N2-N-2*Nsoft;
xzero=zeros(1,Nzero);
xpad=[x xr xzero xl(end:-1:1)];
xpad=xpad+xmean;