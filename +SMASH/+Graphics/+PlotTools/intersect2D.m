% intersect2D Find curve intersections in two dimensions
%
% This function finds curve intersections in a two-dimensional plane.
% These curves are defined by sequential line segements, each of which
% potential intersect with segments from the other curve.  Curves can be
% specified by graphic handles, two-column [x y] arrays, or combinations of
% the two.
%    data=intersect2D(hA,hB); % two graphic handles
%    data=intersect2D(arrayA,arrayB); % two data arrays
%    data=intersect2D(hA,arrayB); % graphic handle and data array
% The output "data" is a two-column [x y] array of intersection points.  An
% empty array is returned if no itersections are found.
%
% Three possibilities exist for each line segment pair (one from each
% curve).
%    1. The segments do not intersect anywhere.
%    2. The segements intersect at one point.
%    3. There are an infinite number of intersections, i.e. the segments
%    overlap one another.
% Only one intersection per segment pair is returned in cases 2-3.
%
% See also SMASH.Graphics.PlotTools
%

%
% created April 24, 2020 by Daniel Dolan (Sandia National Laboratory)
%
function data=intersect2D(sourceA,sourceB)

% manage input
assert(nargin == 2,'ERROR: invalid number of inputs');

if isnumeric(sourceA)
    [M,N]=size(sourceA);
    assert((M >= 2) & (N == 2),'ERROR: invalid curve array');
elseif ishandle(sourceA)
    assert(isscalar(sourceA),'ERROR: cannot intersect multiple graphics');
    type=get(sourceA,'Type');
    switch lower(type)
        case 'line'
            x=get(sourceA,'XData');
            y=get(sourceA,'YData');
            sourceA=[x(:) y(:)];
        otherwise
            error('ERROR: %s intersections not supported',type);
    end    
end

if isnumeric(sourceB)
    [M,N]=size(sourceB);
    assert((M >= 2) & (N == 2),'ERROR: invalid curve array');
elseif ishandle(sourceB)
    assert(isscalar(sourceB),'ERROR: cannot intersect multiple graphics');
    type=get(sourceB,'Type');
    switch lower(type)
        case 'line'
            x=get(sourceB,'XData');
            y=get(sourceB,'YData');
            sourceB=[x(:) y(:)];
        otherwise
            error('ERROR: %s intersections not supported',type);
    end    
end

% extract line data
xA=sourceA(:,1);
yA=sourceA(:,2);
M=size(sourceA,1)-1;

xB=sourceB(:,1);
yB=sourceB(:,2);

% normalize data
xmin=min(min(xA),min(xB));
xmax=max(max(xA),max(xB));
Lx=xmax-xmin;
xA=(xA-xmin)/Lx;
xB=(xB-xmin)/Lx;

ymin=min(min(yA),min(yB));
ymax=max(max(yA),max(yB));
Ly=ymax-ymin;
yA=(yA-ymin)/Ly;
yB=(yB-ymin)/Ly;

% look for intersections
data=nan(0,2);
matrix=nan(2,2);
vector=nan(2,1);

xm=[xA(1:end-1) xA(2:end)];
ym=[yA(1:end-1) yA(2:end)];
drop=any(isnan(xm) | isnan(ym),2);
keep=~drop;
xm=xm(keep,:);
ym=ym(keep,:);

xn=[xB(1:end-1) xB(2:end)];
yn=[yB(1:end-1) yB(2:end)];
drop=any(isnan(xn) | isnan(yn),2);
keep=~drop;
xn=xn(keep,:);
yn=yn(keep,:);
for m=1:M 
    left=min(xm(m,:));
    right=max(xm(m,:));
    bottom=min(ym(m,:));
    top=max(ym(m,:));
    %index=(all(xn,2) < left);
    drop=all(xn < left,2) | all(xn > right,2) | all(yn < bottom,2) | all(yn > top,2);
    keep=~drop;
    N=sum(keep);
    if N == 0
        continue
    end    
    xk=xn(keep,:);
    yk=yn(keep,:);
    for k=1:N                                  
        matrix(1,1)=xm(m,1)-xm(m,2);
        matrix(2,1)=ym(m,1)-ym(m,2);
        matrix(1,2)=xk(k,2)-xk(k,1);
        matrix(2,2)=yk(k,2)-yk(k,1);
        vector(1)=xm(m,1)-xk(k,1);
        vector(2)=ym(m,1)-yk(k,1);
        [param,~]=linsolve(matrix,vector);
        if any(param < 0) || any(param > 1)
            continue
        end
        data(end+1,:)=nan; %#ok<AGROW>
        data(end,1)=xm(m,1)+(xm(m,2)-xm(m,1))*param(1);
        data(end,2)=ym(m,1)+(ym(m,2)-ym(m,1))*param(1);
    end
end

% undo normalization
data(:,1)=xmin+data(:,1)*Lx;
data(:,2)=ymin+data(:,2)*Ly;

end