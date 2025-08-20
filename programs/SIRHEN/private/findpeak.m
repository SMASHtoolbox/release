% findpeak : determine the position, width, and strength of a peak
%
% Usage:
% >> result=findpeak(x,y,options);
%
% Required input:
%    x : horizontal data array
%    y : vertical data array
% Both arrays must be the same size
%
% Optional input may be passed through a structure containing one or more
% of the following fields (square brackets indicated defaults)l.
%   -method ('robust',['maximum'],'centroid','median','parabola','gaussian')
%   -threshold [50%]
%   -fullwidth [inf]
%   -minpoints [3]
%   -xmin [-inf]
%   -xmax [+inf]
%
% Output:
% The result array is a 3xN matrix, where N is the number of (x,y) data
% points.  Each row contains information about the peak:
%   -The first row is the peak location.
%   -The second row is the peak width.
%   -The third row is the peak amplitude.  
% Analysis failure is indicated by NaN value(s).

% created 2/9/2010 by Daniel Dolan
% updated 3/3/2010 by Daniel Dolan
%   -added 'robust' method and made it the default choice
% updated 10/12/2010 by Daniel Dolan
%   -incorporated method selection into an options structure
%   -added xmin and xmax options
function result=findpeak(x,y,options)

% handle input
if nargin<2
    error('ERROR: missing x and y inputs');
end
if (nargin<3) || isempty(options)
    options=struct();
end

% process options
if ~isfield(options,'method') || isempty(options.method)
    options.method='maximum';
end
options.method=lower(options.method);

if ~isfield(options,'threshold') || isempty(options.threshold)
    options.threshold=0.50; % 50% of the peak
end
options.threshold=abs(options.threshold);

if ~isfield(options,'fullwidth') || isempty(options.fullwidth)
    options.fullwidth=max(x)-min(x);
end
options.fullwidth=abs(options.fullwidth);

if ~isfield(options,'minpoints') || isempty(options.minpoints)
    options.minpoints=3;
end
options.minpoints=ceil(abs(options.minpoints));

if ~isfield(options,'xmin') || isempty(options.xmin)
    options.xmin=-inf;
end

if ~isfield(options,'xmax') || isempty(options.xmax)
    options.xmax=+inf;
end

% define output array
result=zeros(3,1); % location, width, amplitude

% apply absolute horizontal limits
keep=(x>=options.xmin) & (x<=options.xmax);
x=x(keep);
y=y(keep);

% robust method uses entire spectrum
if strcmp(options.method,'robust')
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
if rem(options.minpoints,2)==1 % odd number
    Mleft=(options.minpoints-1)/2;
    Mright=Mleft;
else % even number
    Mleft=options.minpoints/2;
    Mright=Mleft+1;
end

[ypeak,index]=max(y);
xpeak=x(index);
threshold=options.threshold*ypeak;

xbound=xpeak-options.fullwidth/2;
change=0;
for kleft=index:-1:1
    change=change+1;
    if change<Mleft
        continue
    elseif (y(kleft)<=threshold) || (x(kleft)<=xbound)
        break       
    end   
end

xbound=xpeak+options.fullwidth/2;
change=0;
for kright=index:1:numel(x)
    change=change+1;
    if change<Mright
        continue
    elseif (y(kright)<=threshold) || (x(kright)>=xbound)
        break       
    end   
end

index=kleft:kright;
x=x(index);
y=y(index);

% locate peak position, width, and amplitude
try
    switch options.method
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
            error('ERROR: %s is an invalid method',options.method);
    end
catch
    result(1:3)=nan;
end

end