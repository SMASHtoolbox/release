function analyzeReference(object)

M=size(object.ReferenceTable,1);
assert(M >= 3,'ERROR: at least three points needed for reference analysis');

m=object.ReferenceTable(:,1);
n=object.ReferenceTable(:,2);
theta=calculateMaxAngle([m n]);
assert(theta >= 10,'ERROR: insufficient reference span');

% log scaling
x=object.ReferenceTable(:,3);
switch object.LogScaling
    case {'horizontal' 'both'}
        x=log10(x);
end

y=object.ReferenceTable(:,4);
switch object.LogScaling
    case {'vertical' 'both'}
        y=log10(y);
end

% matrix analysis
Q=ones(M,3);
Q(:,2)=m;
Q(:,3)=n;

object.ParameterMatrix=Q\[x y];

end

% calculateMaxAngle Calculate max angle
% This function calculates the maximum angle spanned by a table of (x,y) points.
%    theta=calculateMaxAngle(table); % angle returned in degrees
% NOTE: both table columns must have the same units (e.g., pixels) for the calculation to be meaningful
%
function result=calculateMaxAngle(table)

try
    index=convhull(table,'Simplify',true);
catch
    result=0;
    return
end
result=0;
index=unique(index);
x=table(index,1);
y=table(index,2);
M=numel(x);
for m=1:M
    if m == 1
        k=[M 1 2];
    elseif m == M
        k=[M-1 M 1];
    else
        k=[m-1 m m+1];
    end
    u=[x(k(1))-x(k(2)) y(k(1))-y(k(2))];
    v=[x(k(3))-x(k(2)) y(k(3))-y(k(2))];
    u=u/norm(u);
    v=v/norm(v);
    theta=acosd(dot(u,v));
    if theta > 90
        theta=180-theta;
    end
    result=max(result,theta);
end

end