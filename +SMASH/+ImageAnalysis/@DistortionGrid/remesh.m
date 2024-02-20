% REMESH Generate corrected mesh arrays
% 
% This method generates corrected mesh arrays from the isomesh arrays in a
% Distortion object.
%    >> object=remesh(object);
%
% See also Distortion, apply, blur, visualize
%

%
% created January 13, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=remesh(object)

% locate center
x0=mean(object.IsoMesh1(:));
y0=mean(object.IsoMesh2(:));
L2=(object.IsoMesh1-x0).^2+(object.IsoMesh2-y0).^2;
[L2,row]=min(L2);
[~,column]=min(L2);
row=row(column);
x0=object.IsoMesh1(row,column);
y0=object.IsoMesh2(row,column);

% first grid
[distance,direction]=...
    arclength(object.IsoMesh1(:,column),object.IsoMesh2(:,column));
distance=distance-distance(row);

distance=repmat(distance,1,size(object.IsoMesh1,2));
if abs(direction(1))>abs(direction(2))    
    if dot(direction,[distance(end)-distance(1) 0])<0
        distance=-distance;
    end
    object.ArcMesh1=distance+x0;
else
    if dot(direction,[0 distance(end)-distance(1)])<0
        distance=-distance;
    end
    object.ArcMesh2=distance+y0;
end

% second grid
[distance,direction]=...
    arclength(object.IsoMesh1(row,:),object.IsoMesh2(row,:));
distance=distance-distance(column);

distance=repmat(distance,size(object.IsoMesh2,1),1);
if abs(direction(2))>abs(direction(1))
    if dot(direction,[0 distance(end)-distance(1)])<0
        distance=-distance;
    end
    object.ArcMesh2=distance+y0;
else
    if dot(direction,[distance(end)-distance(1) 0])<0
        distance=-distance;
    end
    object.ArcMesh1=distance+x0;
end


end