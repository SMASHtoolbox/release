% analyze Analyze step wedge
%
% This method analyzes the step wedge image to determine how
% measured optical density maps to film exposure.  
%     object=analyze(object);
% Analysis must be performed before the apply method can be used.
%
% Step wedge analysis several intermediate steps.
%   -The user is prompted to crop the measurement (if not already done).
%   -Automatic rotation is applied to orient the measurement.
%   -Constant regions are identified by transitions of peak slope.
%   -Median values from each constant region are associated with total
%   optical density (step value plus offset)
% Analysis is controlled by various settings (derivative parameters, etc.).
%  These settings may be adjusted using the "configure" method.
%
% By default, this method fits a 4th order polynomial to the middle 95% of
% the wedge's range.  These settings can be modified as follows.
%    object=analyze(object,'middle','Range',[lower upper],'Order',N);
% Lower/upper range values must be between 0 and 1.  Polynomial order must
% be an integer, and values are typically 2--6; higher values are permitted
% but may produce unphysical results.
%
% The full wedge range can also be analyzed.
%    object=analyze(object,'full');
% Full range analysis divides the step wedge into three domains: fog,
% active, and saturation.  
%    -The fog domain is  a constant density from the lowest exposure,
%    spanning all points within the density tolerance (default 0.05) of the
%    lowest exposure point.
%    -The saturation domain is a constant density at the highest permitted
%    value of the densitometer.  This region only exists when measured
%    densities are exactly the same at high exposures.
%    -The active domain is a monotonic density function between the fog and
%    saturation domains.  The slope of the active domain is continuous with
%    the fog domain but *not* the saturation domain.
% Full wedge analysis parameters can be adjusted as shown below.
%    object=analyze(object,'full','Order',N,'FogTolerance',tol);
% NOTE: 'full' analysis enforces the monotonic increase of film density
% with exposure at any polynomial order.
%
% See also StepWedge, apply, configure, clean, crop, rotate, tweak
%

%
% created August 28, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=analyze(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='middle';
end
assert(ischar(mode),'ERROR: invalid analysis mode');

% initial preparations
if ~object.Cropped
    object=crop(object,'manual');
end

object=rotate(object,'auto');
object=locate(object);
object=generate(object);

% perform analysis
x=object.Results.TransferPoints(:,1);
y=object.Results.TransferPoints(:,2);
switch lower(mode)
    case 'middle'
        [xs,ys,option]=analyzeMiddle(x,y,varargin{:});
        option.Mode='middle';
    case 'full'
        [xs,ys,option]=analyzeFull(x,y,varargin{:});
        option.Mode='full';
    otherwise
        error('ERROR: "%s" is not a valid analyze mode',mode);
end

numpoints=1000;
xsn=linspace(min(xs),max(xs),numpoints);
ys=interp1(xs,ys,xsn);
xs=xsn;

table=[10.^(xs(:)) ys(:)];
object.Results.ForwardTable=table;

table=table(:,end:-1:1);
start=find(table(:,1)==table(1,1),1,'last');
table=table(start:end,:);
stop=find(table(:,1)==table(end,1),1,'first');
table=table(1:stop,:);
object.Results.ReverseTable=table;

object.Analyzed=true;
view(object,'Results');

% handle output
if nargout==0
    % do nothing
else    
    object.Analyzed=true;
    varargout{1}=object;  
    varargout{2}=option;
end

end

function [xs,ys,option]=analyzeMiddle(x,y,varargin)

% manage input
Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
option=struct('Range',[0.025 0.975],'Order',4);
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    assert(isnumeric(value),'ERROR: invalid option value');
    switch lower(name)
        case 'range'
            assert((numel(value)==2) && all(value>0) && all(value<1),...
                'ERROR: invalid range');            
            option.Range=sort(value);
        case 'order'
            assert(isscalar(value) && (value>0) && (value==round(value)),...
                'ERROR: invalid order');
            option.Order=value;
        otherwise
            error('ERROR: "%s" is not a valid analysis option');
    end
end

% analyze data inside specified range
min_y=min(y);
max_y=max(y);
Ly=max_y-min_y;
y1=min_y+option.Range(1)*Ly;
y2=min_y+option.Range(2)*Ly;

keep=(y>=y1)&(y<=y2);
p=polyfit(x(keep),y(keep),option.Order);
xs=linspace(min(x(keep)),max(x(keep)),1000);
ys=polyval(p,xs);

pd=polyder(p);
slope=polyval(pd,xs(end));
y0=mean(y(y>=y2));
x0=xs(end)-(ys(end)-y0)/slope; % project curve to upper bound
xs(end+1)=x0;
ys(end+1)=y0;

slope=polyval(polyder(p),xs(1));
y0=mean(y(y<=y1));
x0=xs(1)-(ys(1)-y0)/slope; % project curve to lower bound
xs(end+1)=x0;
ys(end+1)=y0;

[xs,index]=sort(xs);
ys=ys(index);

end

function [xs,ys,option]=analyzeFull(x,y,varargin)

% manage input
table=[x(:) y(:)];
table=sortrows(table);
x=table(:,1);
y=table(:,2);
numpoints=numel(x);

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
option=struct('Range',[0.025 0.975],'Order',4,...
    'FogTolerance',0.05,'Optimization',optimset());
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    %assert(isnumeric(value),'ERROR: invalid option value');
    switch lower(name)
        case 'range'
            assert(isnumeric(value) && (numel(value)==2) && all(value>0) && all(value<1),...
                'ERROR: invalid range');            
            option.Range=sort(value);
        case 'order'
            assert(isnumeric(value) && isscalar(value) && (value>0) && (value==round(value)),...
                'ERROR: invalid order');
            option.Order=value;
        case 'fogtolerance'
            assert(isnumeric(value) && isscalar(value) && (value>0),...
                'ERROR: invalid density tolerance');
            option.FogTolerance=value;
        case 'optimization'
            try
                option.Optimization=optimset(value);
            catch
                error('ERROR: invalid optimization settings');
            end
        otherwise
            error('ERROR: "%s" is not a valid analysis option');
    end
end

% estimate fog region
threshold=y(1)+option.FogTolerance;
k=find(y>threshold,1,'first');
xfog0=x(k-1);

% identify saturation region (if present)
temp=(y(end:-1:1) ~= y(end));
k=find(temp,1,'first');
xsat=x(end-(k-2));

% set up residual function
b=ones(1,option.Order+1);
b(end-1)=0;
fit=[];
vector=[];
matrix=ones(numpoints,1);
FixFog=true;
    function chi2=residual(param)             
        if FixFog
            xfog=xfog0;
        else
            xfog=xfog0+param(1);
            param=param(2:end);
        end
        %yfog=mean(y(x<=xfog));
        yfog=median(y(x<=xfog));
        u=(x-xfog)./(xsat-xfog);              
        b(1:end-2)=param;
        basis=zeros(numpoints,1);
        k=(x>xfog) & (x<xsat);
        c=conv(b,b);
        %c=conv([1 0],c);
        c=polyint(c);
        basis(k)=polyval(c,u(k))-polyval(c,0);
        k=(x>=xsat);
        basis(k)=polyval(c,1)-polyval(c,0);
        matrix(:,1)=basis;
        vector=matrix\(y-yfog);
        fit=matrix*vector+yfog;
        chi2=mean((y-fit).^2);
    end

% initial optimization
FixFog=true;
guess=zeros(1,option.Order-1);
result=fminsearch(@residual,guess,option.Optimization);

% revised optimization
FixFog=false;
guess=zeros(1,option.Order);
guess(2:end)=result;
result=fminsearch(@residual,guess,option.Optimization);

%xs=linspace(min(x),max(x),1000);
%ys=interp1(x,fit,xs);
xs=x;
ys=fit;

end