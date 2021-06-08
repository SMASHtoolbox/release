% verifyGrid validate Signal grid and check direction/uniformity
%
% This method verifies that the Grid array increases or decreases
% monotonically.  Increasing grids are labelled with a GridDirection of
% "normal", while decreasing grids are labelled as "reverse".  Grids that
% vary by less than 1 ppm from the average spacing are labelled as uniform,


function [object,dxmean]=verifyGrid(object)

% determine direction and mean spacing
x=object.Grid;
dxmean=x(end)-x(1);
if dxmean>0
    object.GridDirection='normal';    
else
    object.GridDirection='reverse';    
end
dxmean=dxmean/(numel(x)-1);
object.GridSpacing=dxmean;

% normalized grid analysis
xn=(x-x(1))/dxmean;
dxn=diff(x)/dxmean;
if any(dxn < 0)
    error('ERROR: non-monotonic Grid detected');
elseif any(dxn == 0)
    N=numel(xn);
    [xn,index]=unique(xn);
    if numel(xn) < N
        warning('Eliminating repeated grid points');
    end
    object.Grid=x(1)+dxmean*xn;
    object.Data=object.Data(index);
end

delta=abs(1-dxn);
%tolerance=eps(class(dxn))*1e5;
%tolerance=sqrt(eps(class(dxn)));
tolerance=1e-3;
if any(delta > tolerance)
    object.GridUniform=false;
else
    object.GridUniform=true;
end

end