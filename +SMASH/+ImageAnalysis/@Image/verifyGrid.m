% verifyGrid validate Image grids and check direction/uniformity
%
% This method verifies that the Grid arrays increases or decreases
% monotonically.  Increasing grids are labelled with a GridDirection of
% "normal", while decreasing grids are labelled as "reverse".  The average
% grid spacing is also determined; if the actual grid varies less than 1%
% from this uniform case, GridUniform is set to true.
%

function object=verifyGrid(object)

% check for monotonic increase/decrease
x=object.Grid1;
dx=diff(x);
if all(dx>0) || all(dx<0)
    % valid grid
else
    error('ERROR: non-monotonic Grid1 detected');
end

y=object.Grid2;
dy=diff(y);
if all(dy>0) || all(dy<0)
    % valid grid
else
    error('ERROR: non-monotonic Grid2 detected');
end

% determine direction and mean spacing
dxmean=x(end)-x(1);
if dxmean>0
    object.Grid1Direction='normal';    
else
    object.Grid1Direction='reverse';    
end
dxmean=dxmean/(numel(x)-1);
object.Grid1Spacing=dxmean;

dymean=y(end)-y(1);
if dymean>0
    object.Grid2Direction='normal';    
else
    object.Grid2Direction='reverse';    
end
dymean=dymean/(numel(y)-1);
object.Grid2Spacing=dymean;

% check uniformity
xu=x(1):dxmean:x(end);
xu=reshape(xu,size(x));
delta=abs((x-xu)/dxmean);
if any(delta>1e-2)
    object.Grid1Uniform=false;
else
    object.Grid1Uniform=true;
end

yu=y(1):dymean:y(end);
yu=reshape(yu,size(y));
delta=abs((y-yu)/dymean);
if any(delta>1e-2)
    object.Grid2Uniform=false;
else
    object.Grid2Uniform=true;
end

end