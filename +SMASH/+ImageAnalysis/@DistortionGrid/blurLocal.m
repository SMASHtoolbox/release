%
% created January 10, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=blurLocal(object)

Xold=object.IsoMesh1;
Xnew=Xold;
Yold=object.IsoMesh2;
Ynew=Yold;
[N,M]=size(Xold);
for n=2:(N-1)
    for m=2:(M-1)
       x=[Xold(n,m-1) Xold(n+1,m) Xold(n,m+1) Xold(n-1,m)];
       y=[Yold(n,m-1) Yold(n+1,m) Yold(n,m+1) Yold(n-1,m)];
       [x0,y0]=qdintersect(x,y);
       Xnew(n,m)=x0;
       Ynew(n,m)=y0;
    end
end
object.IsoMesh1=Xnew;
object.IsoMesh2=Ynew;

object=updateHistory(object);

end

function varargout=qdintersect(x,y)

% create edge vectors
index=[1 2];
vectorA=[diff(x(index)) diff(y(index))];
a=norm(vectorA);   % vector magnitude
vectorA=vectorA/a; % unit vector

index=[1 3];    
vectorB=[diff(x(index)) diff(y(index))];
b=norm(vectorB);   % vector magnitude
vectorB=vectorB/b; % unit vector

index=[2 4];    
vectorC=[diff(x(index)) diff(y(index))];
c=norm(vectorC);   % vector magnitude
vectorC=vectorC/c; % unit vector
    
% apply law of sines
theta1=acos(abs(dot(vectorA,vectorB)));
theta2=acos(abs(dot(vectorA,vectorC)));
theta3=pi-theta1-theta2;
z=a*sin(theta2)/sin(theta3);

% project from first point to diagnonal crossing
x0=x(1)+z*vectorB(1);
y0=y(1)+z*vectorB(2);

% handle output
if nargout==0
    figure;
    plot(x,y,'ko',x([1 3]),y([1 3]),'k-',x([2 4]),y([2 4]),'k-',...
        x0,y0,'ksq');
else
    varargout{1}=x0;
    varargout{2}=y0;
end

end