% REGRID Transfer Image object onto a new grid
%
% This method interpolates an existing object into a new object on a
% specified grid.
%    >> new=regrid(object,x,y);
% If no grid is specified, a uniformly spaced grid is calculated from the
% existing grid.
%    >> object=regrid(object);
% This technique may needed before using methods requiring a uniformly
% spaced grid (such as fft).
%
% See also Image, lookup
%

%
% created November 20, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=regrid(object,x,y)

% determine current grid spacing average
N=numel(object.Grid1);
x1=min(object.Grid1);
x2=max(object.Grid1);
spacing1=(x2-x1)/(N-1);
xdir=sign(diff(object.Grid1([1 end])));

N=numel(object.Grid2);
y1=min(object.Grid2);
y2=max(object.Grid2);
spacing2=(y2-y1)/(N-1);
ydir=sign(diff(object.Grid2([1 end])));

% manage input
if (nargin<2) || isempty(x)  
    %x=x1:spacing1:x2;
    x=object.Grid1(1):(xdir*spacing1):object.Grid1(end);
else
    dx=abs(diff(x));
    check=(dx/spacing1-1);
    if any(check>1e-6)
       warning('WARNING: using a coarser grid may cause aliasing');
    end
end

if (nargin<3) || isempty(y)  
    %y=y1:spacing2:y2;
    y=object.Grid2(1):(ydir*spacing2):object.Grid2(end);
else
    dy=abs(diff(y));
    check=(dy/spacing2-1);
    if any(check>1e-6)
       warning('WARNING: using a coarser grid may cause aliasing');
    end
end

% manage limit indices
if isnumeric(object.LimitIndex1)
    [xb,~,~]=limit(object);
    xb=sort(xb([1 end]));
    k=(x>=xb(1)) & (x<=xb(2));
    k=[find(k,1,'first') find(k,1,'last')];
    object.LimitIndex1=k(1):k(2);    
end

if isnumeric(object.LimitIndex2)
    [~,yb,~]=limit(object);
    yb=sort(yb([1 end]));
    k=(y>=yb(1)) & (y<=yb(2));
    k=[find(k,1,'first') find(k,1,'last')];
    object.LimitIndex2=k(1):k(2);    
end

% interpolate onto new grid
z=interp2(object.Grid1,object.Grid2,object.Data,x,y(:),'linear');
object.Grid1=x;
object.Grid2=y;
object.Data=z;

object=verifyGrid(object);
object=updateHistory(object);

end