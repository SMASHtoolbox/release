% REGRID Transfer SignalGroup object onto a new grid
%
% This method interpolates an existing object into a new object on a
% specified grid.
%    >> new=regrid(object,x);
% If no grid is specified, a uniformly spaced grid is calculated from the
% existing grid.
%    >> object=regrid(object);
% This technique may needed before using methods requiring a uniformly
% spaced grid (such as fft).
%
% See also SignalGroup, lookup
%

%
% created November 24, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=regrid(object,x)

% determine current grid spacing average
N=numel(object.Grid);
x1=min(object.Grid);
x2=max(object.Grid);
spacing=(x2-x1)/(N-1);

% manage input
if (nargin<2) || isempty(x)  
    x=x1:spacing:x2;
else
    dx=abs(diff(x));
    ratio=dx/spacing-1;
    if any(ratio>1e-6)
       warning('SMASH:CoarseGrid',...
           'WARNING: using a coarser grid may cause aliasing');
    end
end

% manage limit index
if isnumeric(object.LimitIndex)
    [xb,~]=limit(object);
    xb=sort(xb([1 end]));
    k=(x>=xb(1)) & (x<=xb(2));
    k=[find(k,1,'first') find(k,1,'last')];
    object.LimitIndex=k(1):k(2);    
end

% interpolate data and update object
table=nan(numel(x),object.NumberSignals);
for n=1:object.NumberSignals
    y=interp1(object.Grid,object.Data(:,n),x,'linear','extrap');
    table(:,n)=y(:);
end
object.Grid=x;
object.Data=table;

object=verifyGrid(object);
object=updateHistory(object);

end