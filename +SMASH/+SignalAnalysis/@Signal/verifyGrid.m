% verifyGrid validate Signal grid and check direction/uniformity
%
% This method verifies that the Grid array increases or decreases
% monotonically.  Increasing grids are labelled with a GridDirection of
% "normal", while decreasing grids are labelled as "reverse".  Grids that
% vary by less than 1 ppm from the average spacing are labelled as uniform,


function [object,dxmean]=verifyGrid(object)

% determine direction
x=object.Grid;
dx=diff(x);
if all(dx >= 0)
    object.GridDirection='normal';
elseif all(dx <= 0)
    object.GridDirection='reverse';
else
    error('ERROR: non-monotonic Grid detected');
end

% elimate repeated points
if any(dx == 0)
    [x,index]=unique(x); 
    warning('Eliminating repeated grid points');
    object.Grid=x;
    object.Data=object.Data(index);
end

% analyze spacing
object.GridUniform=false;
span=abs(x(end)-x(1));
dxmean=span/(numel(x)-1);
object.GridSpacing=dxmean;

u=linspace(0,1,numel(x));
u=u(:); 
x=x(:);
param=polyfit(u,x,1);
err=x-polyval(param,u);
threshold=100*max(eps(span),eps(class(span)));
if all(abs(err) <= threshold)
    object.GridUniform=true;
end

end