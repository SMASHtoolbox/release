% findpeak : determine the position, width, and strength of a peak
%
% Usage:
% >> result=findpeak(x,y,method,params);
%
% Required input:
%    x : horizontal data array
%    y : vertical data array
% Both arrays must be the same size
%
% Optional input:
%   method : peak analysis method ('robust','maximum','centroid','median','parabola','gaussian')
%            Default method is 'maximum'
%   params : struture of peak finding parameters
% Valid parameter fields include 'threshold', 'fullwidth', and 'minpoints'.
% Setting a 'threshold' limits calculations to data that is a specified
% fraction of the maximum vertical value (default is 50%).  Horizontal
% bounds may specified by 'fullwidth', limiting peak location to a horizontal
% region centered on the maximum value with a specified fullwidth (default
% option is to use all data).  A minimum number of data points for peak
% location may also be specified (default is 3).
%
% Output:
% The result array is a 3xN matrix, where N is the number of (x,y) data
% points.  Each row contains information about the peak at each value of x:
%  The first row is the peak location, the second row is the peak width,
%  and the third row is the peak amplitude.  The specific values of each
%  result depend on the analysis method.  Instances where the analysis
%  fails are indicated by NaN values.

% created 2/9/2010 by Daniel Dolan
% updated 3/3/2010 by Daniel Dolan
%   -added 'robust' method and made it the default choice
function result=findpeak(x,y,method,params)

% handle input
if nargin<2
    error('ERROR: missing x and y inputs');
end

if (nargin<3) || isempty(method)
    %method='maximum';
    method='robust';
end
method=lower(method);

if (nargin<4) || isempty(params)
    params=struct();
end
if ~isfield(params,'threshold') || isempty(params.threshold)
    params.threshold=0.50; % 50% of the peak
else
    params.threshold=abs(params.threshold);
end
if ~isfield(params,'fullwidth') || isempty(params.fullwidth)
    params.fullwidth=max(x)-min(x);
else
    params.fullwidth=abs(params.fullwidth);
end
if ~isfield(params,'minpoints') || isempty(params.minpoints)
    params.minpoints=3;
else
    params.minpoints=ceil(abs(params.minpoints));
end
if ~isfield(params,'xrange') || isempty(params.xrange)
    params.xrange=[-inf +inf];
end

% define output array
result=zeros(3,1); % location, width, amplitude

% limit data by specified range
index=(x>=params.xrange(1)) & (x<=params.xrange(2));
x=x(index);
y=y(index);

% robust method uses entire spectrum
if strcmp(method,'robust')
    keep=repmat(true,size(x));
    for n=1:3
        xk=x(keep);
        yk=y(keep);
        area=trapz(xk,yk);
        weight=yk/area;
        xm=trapz(xk,xk.*weight);
        L=sqrt(trapz(xk,(xk-xm).^2.*weight));
        xb=xm+2*[-L +L];
        keep=(x>=xb(1)) & (x<=xb(2));
    end
    result(1)=xm;
    result(2)=L;
    result(3)=area;
    return
end

% crop data around peak
if rem(params.minpoints,2)==1 % odd number
    Mleft=(params.minpoints-1)/2;
    Mright=Mleft;
else % even number
    Mleft=params.minpoints/2;
    Mright=Mleft+1;
end

[ypeak,index]=max(y);
xpeak=x(index);
threshold=params.threshold*ypeak;

xbound=xpeak-params.fullwidth/2;
change=0;
for kleft=index:-1:1
    change=change+1;
    if change<Mleft
        continue
    elseif (y(kleft)<=threshold) || (x(kleft)<=xbound)
        break       
    end   
end

xbound=xpeak+params.fullwidth/2;
change=0;
for kright=index:1:numel(x)
    change=change+1;
    if change<Mright
        continue
    elseif (y(kright)<=threshold) || (x(kright)>=xbound)
        break       
    end   
end
% [ypeak,index]=max(y(1+Mleft:end-Mright));
% index=index(1)+Mleft;
% 
% 
% 
% 
% for mleft=(index-Mleft):-1:1
%     if (y(mleft)<=threshold) || (x(mleft)<=xbound)
%         break
%     end
% end
% xbound=xpeak+params.fullwidth/2;
% for mright=(index+Mright):numel(y)
%     if (y(mright)<=threshold) || (x(mright)>=xbound)
%         break
%     end
% end

index=kleft:kright;
x=x(index);
y=y(index);

% locate peak position, width, and amplitude
try
    switch method
        case 'maximum'
            result(1)=xpeak;
            result(2)=(max(x)-min(x))/2;
            result(3)=ypeak;
        case 'centroid'
            weight=y/trapz(x,y);
            result(1)=trapz(x,weight.*x);
            result(2)=sqrt(trapz(x,weight.*(x-result(1)).^2));
            result(3)=mean(y);
        case 'median'
            weight=cumtrapz(x,y);
            weight=weight/weight(end);
            index=[0 0];
            index(1)=find(weight<0.25,1,'last');
            index(2)=index(1)+1;
            x25=interp1(weight(index),x(index),0.25,'linear');
            index(1)=find(weight<0.50,1,'last');
            index(2)=index(1)+1;
            x50=interp1(weight(index),x(index),0.50,'linear');
            index(1)=find(weight<0.75,1,'last');
            index(2)=index(1)+1;
            x75=interp1(weight(index),x(index),0.75,'linear');
            result(1)=x50;
            result(2)=(x75-x25)/2;
            result(3)=interp1(x,y,x75,'linear');
        case 'parabola'
            x0=min(x);
            Lx=max(x)-x0;
            x=(x-x0)/Lx;
            y0=min(y);
            Ly=max(y)-y0;
            y=(y-y0)/Ly;
            a=polyfit(x,y,2);
            xp=-a(2)/(2*a(1)); % peak location
            LR=abs(1/(2*a(1))); % latus rectum
            result(1)=Lx*xp+x0; % undo normalization
            result(2)=Lx*LR; % undo normalization
            result(3)=Ly*polyval(a,result(1))+y0;
        case 'gaussian'
            [a,fit]=gaussianfit(x,y);
            result(1)=a(3);
            result(2)=a(4);
            result(3)=a(2);
        otherwise
            error('ERROR: %s is an invalid method',method);
    end
catch
    result(1:3)=nan;
end

end