% REGRID Transfer Signal object onto a new grid
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
% See also Signal, lookup
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
% updated December 20, 2013 by Daniel Dolan
%    -fixed interaction between regrid and limit
%
function object=regrid(object,x)

% determine current grid spacing average
N=numel(object.Grid);
x1=min(object.Grid);
x2=max(object.Grid);
spacing=(x2-x1)/(N-1);

% probe existing bounds
bound=object.LimitIndex;
if isnumeric(bound)
    bound=object.Grid(bound);
    bound=bound([1 end]);    
end

% manage input
if (nargin<2) || isempty(x)  
    x=x1:spacing:x2;
elseif numel(x)==1
    dx=x;
    %testSpacing;
    x=x1:dx:x2;
else
    %dx=abs(diff(x));
    %testSpacing;
end
x=x(:);
    %function testSpacing()
    %    value=abs(dx/spacing)-1;
    %    if any(value>1e-6)
    %         warning('SMASH:alias',...
    %             'Mapping to a coarser grid may cause aliasing');
    %    end
    %end

% manage limit index
if isnumeric(object.LimitIndex)
    [xb,~]=limit(object);
    xb=sort(xb([1 end]));
    k=(x>=xb(1)) & (x<=xb(2));
    k=[find(k,1,'first') find(k,1,'last')];
    object.LimitIndex=k(1):k(2);    
end

% interpolate data and update object
y=interp1(object.Grid,object.Data,x,'linear');
object.Grid=x;
object.Data=y;
object=limit(object,bound);

% finish up
object=verifyGrid(object);
object=updateHistory(object);

end