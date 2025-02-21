% MESH Generate isomesh arrays 
% 
% This method generates isomesh arrays from the isopoints in a Distortion
% object.
%    >> object=mesh(object);
% 
% See also Distortion, apply, blur, visualize
%

%
% created January 7, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=mesh(object)

% extract isopoints
[x,y]=table2cells(object.IsoPoints);
NumberGroups=numel(x);

keep=true(NumberGroups,1);
for n=1:NumberGroups
    if numel(x{n})<2
        fprintf('Groups with fewer than two isopoints cannot be incorporated into the isomesh \n');
        keep(n)=false;
    end
end
x=x(keep);
y=y(keep);
NumberGroups=numel(x);

% enforce consistent group direction
direction=nan(NumberGroups,2);
for n=1:NumberGroups
    direction(n,1)=x{n}(end)-x{n}(1);
    direction(n,2)=y{n}(end)-y{n}(1);
    direction(n,:)=direction(n,:)/norm(direction(n,:));
end

vector=sum(direction,1);
vector=vector/norm(vector);
for n=1:NumberGroups
    if dot(vector,direction(n,:))<0
        x{n}=x{n}(end:-1:1);
        y{n}=y{n}(end:-1:1);
    end
end

% sort groups based on centroid
table=nan(NumberGroups,2);
for n=1:NumberGroups
    table(n,1)=mean(x{n});
    table(n,2)=mean(y{n});
end
[~,index]=vmsort(table);
x=x(index);
y=y(index);

% identify center points
CenterGroup=floor((1+NumberGroups)/2);
mc=floor((1+numel(x{CenterGroup}))/2);
x0=x{CenterGroup}(mc);
y0=y{CenterGroup}(mc);

CenterPoint=repmat(mc,[NumberGroups 1]);
for m=[1:CenterGroup-1 CenterGroup+1:NumberGroups]
    L2=(x{m}-x0).^2+(y{m}-y0).^2;
    [~,CenterPoint(m)]=min(L2);    
end

% extend groups as neccessary
NumberPoints=cellfun(@numel,x);
NumberPoints=NumberPoints(:);
BeforePoints=CenterPoint-1;
BeforePoints=max(BeforePoints)-BeforePoints;
AfterPoints=NumberPoints-CenterPoint;
AfterPoints=max(AfterPoints)-AfterPoints;

for n=1:NumberGroups    
    for m=1:AfterPoints(n)
        dx=x{n}(end)-x{n}(end-1);
        x{n}(end+1)=x{n}(end)+dx;
        dy=y{n}(end)-y{n}(end-1);        
        y{n}(end+1)=y{n}(end)+dy;
    end
    for m=1:BeforePoints(n)
        dx=x{n}(1)-x{n}(2);
        x{n}(2:end+1)=x{n};
        x{n}(1)=x{n}(1)+dx;
        dy=y{n}(1)-y{n}(2);
        y{n}(2:end+1)=y{n};
        y{n}(1)=y{n}(1)+dy;
    end        
end

% build isomesh arrays
temp=nan(numel(x{1}),NumberGroups);
object.IsoMesh1=temp;
object.IsoMesh2=temp;
for n=1:NumberGroups
    object.IsoMesh1(:,n)=x{n};
    object.IsoMesh2(:,n)=y{n};
end

end