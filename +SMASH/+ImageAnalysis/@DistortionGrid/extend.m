% EXTEND Extend isomesh by one point in each direction
%
% This method adds new mesh points to an existing Distrotion object, extending
% the mesh boundaries vertically and horizontally.
%
% Usage:
%   >> object=extend(object);
%
% See also Distortion, apply, locate, visualize
%

% created January 13, 2014 by Daniel Dolan (Sandia National Laboratories)
function object=extend(object)

xmesh=object.IsoMesh1;
ymesh=object.IsoMesh2;

% vertical extension
x1=xmesh(2,:);
y1=ymesh(2,:);
x2=xmesh(1,:);
y2=ymesh(1,:);
Dx=x2-x1;
Dy=y2-y1;
x=x2+Dx;
y=y2+Dy;
xmesh(2:end+1,:)=xmesh;
xmesh(1,:)=x;
ymesh(2:end+1,:)=ymesh;
ymesh(1,:)=y;

x1=xmesh(end-1,:);
y1=ymesh(end-1,:);
x2=xmesh(end,:);
y2=ymesh(end,:);
Dx=x2-x1;
Dy=y2-y1;
x=x2+Dx;
y=y2+Dy;
xmesh(end+1,:)=x;
ymesh(end+1,:)=y;

% horizontal extension
x1=xmesh(:,2);
y1=ymesh(:,2);
x2=xmesh(:,1);
y2=ymesh(:,1);
Dx=x2-x1;
Dy=y2-y1;
x=x2+Dx;
y=y2+Dy;
xmesh(:,2:end+1)=xmesh;
xmesh(:,1)=x;
ymesh(:,2:end+1)=ymesh;
ymesh(:,1)=y;

x1=xmesh(:,end-1);
y1=ymesh(:,end-1);
x2=xmesh(:,end);
y2=ymesh(:,end);
Dx=x2-x1;
Dy=y2-y1;
x=x2+Dx;
y=y2+Dy;
xmesh(:,end+1)=x;
ymesh(:,end+1)=y;

% return updated mesh
object.IsoMesh1=xmesh;
object.IsoMesh2=ymesh;
object=remesh(object);