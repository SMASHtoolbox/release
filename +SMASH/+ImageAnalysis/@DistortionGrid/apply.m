% APPLY Remove distortion from an Image object
%
% This method removes geometric distortion from a target object using the
% information stored in a Distortion object.
%    >> result=apply(object,target);
% The second input "target" can be an object of the Image class or any
% subclass of Image.
%
% Local Jacobian corrections are calculated but not applied by this method.
%  To make this correction manually, use a second output as shown below.
%    >> [result,jacobian]=apply(object,target);
%    >> result=result.*jacobian;
%
%
% See also Distortion, blur, locate
%

%
% created January 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function [target,jacobian]=apply(object,target)

% handle input
if ~isa(target,'SMASH.ImageAnalysis.Image')
    error('ERROR: target object must be an Image object');
end

% extract information from the source object
XMesh=object.IsoMesh1;
YMesh=object.IsoMesh2;
PMesh=object.ArcMesh1;
QMesh=object.ArcMesh2;

% allocate arrays
p=(target.Grid1>=min(XMesh(:))) & (target.Grid1<=max(XMesh(:))); % temporary assignment
p=linspace(min(PMesh(:)),max(PMesh(:)),sum(p)); % permanent assignment 
q=(target.Grid2>=min(YMesh(:))) & (target.Grid2<=max(YMesh(:))); % temporary assignment
q=linspace(min(QMesh(:)),max(QMesh(:)),...
    sum(q)); % permanent assignment 
[X,Y,jacobian]=deal(nan(numel(q),numel(p)));

% transform (p,q) array to (x,y) in mesh blocks
[N,M]=size(XMesh);
matrix=ones(4,4);
for n=1:(N-1)
    for m=1:(M-1)
        % determine block transfer parameters
        xvector=[XMesh(n,m); XMesh(n+1,m); XMesh(n+1,m+1); XMesh(n,m+1)];
        yvector=[YMesh(n,m); YMesh(n+1,m); YMesh(n+1,m+1); YMesh(n,m+1)];
        pvector=[PMesh(n,m); PMesh(n+1,m); PMesh(n+1,m+1); PMesh(n,m+1)];
        qvector=[QMesh(n,m); QMesh(n+1,m); QMesh(n+1,m+1); QMesh(n,m+1)];
        matrix(:,2)=pvector;
        matrix(:,3)=qvector;
        matrix(:,4)=pvector.*qvector;        
        a=matrix \ xvector;
        b=matrix \ yvector;
        % apply transformation to points inside the block
        temp=PMesh(n:n+1,m:m+1);
        temp=temp(:);
        index_p=(p>=min(temp)) & (p<max(temp));
        P=p(index_p);
        temp=QMesh(n:n+1,m:m+1);
        temp=temp(:);
        index_q=(q>=min(temp)) & (q<max(temp));
        Q=q(index_q);
        [P,Q]=meshgrid(P,Q);
        XT=a(1)+a(2)*P+a(3)*Q+a(4)*P.*Q;
        YT=b(1)+b(2)*P+b(3)*Q+b(4)*P.*Q;
        X(index_q,index_p)=XT;
        Y(index_q,index_p)=YT;        
        jacobian(index_q',index_p)=...
            (a(2)+a(4)*YT).*(b(3)+b(4)*XT)-(b(2)+b(4)*YT).*(a(3)+a(4)*XT);
    end
end

% apply transformation to the target object
target=reset(target,p,transpose(q),...
    interp2(target.Grid1,target.Grid2,target.Data,X,Y));
%target.Data=interp2(target.Grid1,target.Grid2,target.Data,X,Y);
%%target.Data=target.Data.*jacobian;
%target.Grid1=p;
%target.Grid2=transpose(q);

%target.ObjectHistory{end+1}='Distortion.apply';

end
