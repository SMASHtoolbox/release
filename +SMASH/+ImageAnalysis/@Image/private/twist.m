function object=twist(object,theta)

% convert angle from degrees to radians
theta=theta*(pi/180);

% create (x,y) grid
x=object.Grid1;
xc=mean(x);
x=x-xc;
Lx=numel(x);

y=object.Grid2;
yc=mean(y);
y=y-yc;
Ly=numel(y);

z=object.Data;

% create interpolation grid
xb=[min(x) max(x) max(x) min(x)];
yb=[min(y) min(y) max(y) max(y)];
xbi=+cos(theta)*xb(:)+sin(theta)*yb(:);
ybi=-sin(theta)*xb(:)+cos(theta)*yb(:);
dxi=(max(xbi)-min(xbi))/(Lx-1);
dyi=(max(ybi)-min(ybi))/(Ly-1);
xi=(min(xbi)-dxi):dxi:(max(xbi)+dxi);
yi=(min(ybi)-dyi):dyi:(max(ybi)+dyi);

object.Grid1=xi;
object.Grid2=yi;

% interpolate original data onto new grid
[x,y]=meshgrid(x,y);
[xi,yi]=meshgrid(xi,yi);
xnew=+cos(theta)*xi-sin(theta)*yi;
ynew=+sin(theta)*xi+cos(theta)*yi;
object.Data=interp2(x,y,z,xnew,ynew,'linear',nan);

% 
% 
% 
% % create interpolation grid
% xi=+cos(theta)*x(:)-sin(theta)*y(:);
% yi=+sin(theta)*x(:)+cos(theta)*y(:);
% xi=reshape(xi,size(x));
% yi=reshape(yi,size(y));
% 
% % interpolate image onto new grid
% zi=interp2(x,y,z,xi,yi,'linear');
% %xi=xi(1,:);
% xi=x(1,:);
% %yi=yi(:,1);
% yi=y(:,1);

end