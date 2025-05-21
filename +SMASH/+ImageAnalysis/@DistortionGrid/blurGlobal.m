%
% created January 10, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=blurGlobal(object,order)

% handle input
if (nargin<2) || isempty(order)
    order=1;
end
assert(isnumeric(order),'ERROR: order must be numeric');
if numel(order)==1
    order=repmat(order,[1 2]);
else
    order=order(1:2);
end

% alter isomesh
Xold=object.IsoMesh1;
Yold=object.IsoMesh2;
[N,M]=size(Xold);
[Xnew,Ynew]=deal(nan(N,M));
for n=1:N
    for m=1:M
        [xc,yc]=findIntersection(Xold(n,m),Yold(n,m),...
            Xold(n,:),Yold(n,:),order(1),...
            Xold(:,m),Yold(:,m),order(2));
        Xnew(n,m)=xc;
        Ynew(n,m)=yc;
    end
end
object.IsoMesh1=Xnew;
object.IsoMesh2=Ynew;

end

function [xc,yc]=findIntersection(xc,yc,xA,yA,NA,xB,yB,NB)

LxA=max(xA)-min(xA);
LxB=max(xB)-min(xB);
if LxB>LxA
    [xc,yc]=findIntersection(xc,yc,xB,yB,NB,xA,yA,NA);
    return
end
LyA=max(yA)-min(yA);
LyB=max(yB)-min(yB);

% generate curves
x0A=mean(xA);
y0A=mean(yA);
paramA=polyfit((xA-x0A)/LxA,(yA-y0A)/LyA,NA);
    function y=curveA(x)
        x=(x-x0A)/LxA;
        y=polyval(paramA,x);
        y=y0A+y*LyA;
    end

x0B=mean(xB);
y0B=mean(yB);
paramB=polyfit((yB-y0B)/LyB,(xB-x0B)/LxB,NB);
    function x=curveB(y)
        y=(y-y0B)/LyB;
        x=polyval(paramB,y);
        x=x0B+x*LxB;
    end

% iterate to intersection
for iteration=1:5
    yc=curveA(xc);
    xc=curveB(yc);
end

end