% MERGE Merge Image objects into a single object
%
% This method merges mutiple Image objects into a single object.
%    >> new=merge(object1,object2,...);
% The new object Grid is determined by the outermost points of the source
% objects, spaced by the smallest source grid spacings.  Source objects are
% added to this new grid sequentially.  Overlapping information is averaged
% by the number of source contributions at every point. Points that do not
% correspond to any source object are assigned to NaN.
%
% Merged objects inherit most of their properties from the first source
% object, though Grid, Data, and LimitIndex are obviously changed in the
% process.  The object Source is updated to reflect this change and the
% ObjectHistory is reset.
%
% See also Image
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=merge(varargin)

assert(nargin>1,'ERROR: at least two objects needed')

[left,right,dx,top,bottom,dy]=deal(nan(nargin,1));
for n=1:nargin  
    assert(isa(varargin{n},'SMASH.ImageAnalysis.Image'),...
        'ERROR: non-Image input detected')
    if ~varargin{n}.Grid1Uniform || ~varargin{n}.Grid2Uniform
        varargin{n}=regrid(varargin{n});
    end
    temp=varargin{n}.Grid1;
    left(n)=min(temp);
    right(n)=max(temp);
    dx(n)=(right(n)-left(n))/(numel(temp)-1);
    temp=varargin{n}.Grid2;
    bottom(n)=min(temp);
    top(n)=max(temp);
    dy(n)=(top(n)-bottom(n))/(numel(temp)-1);
end
width=max(right)-min(left);
dx=min(dx);
Nx=1+ceil(width/dx);
height=max(top)-min(bottom);
dy=min(dy);
Ny=1+ceil(height/dy);


x=linspace(min(left),max(right),Nx);
y=linspace(min(bottom),max(top),Ny);
[z,count]=deal(nan(numel(y),numel(x)));
for n=1:nargin
    xtemp=varargin{n}.Grid1;
    keepx=(x>=left(n)) & (x<=right(n));    
    ytemp=varargin{n}.Grid2;
    keepy=(y>=bottom(n)) & (y<=top(n));
    ztemp=z(keepy,keepx);
    ztemp(isnan(ztemp))=0;
    ctemp=count(keepy,keepx);
    ctemp(isnan(ctemp))=0;
    [X,Y]=meshgrid(x(keepx),y(keepy));
    z(keepy,keepx)=ztemp+interp2(xtemp,ytemp,varargin{n}.Data,X,Y);
    count(keepy,keepx)=ctemp+1;
end

object=varargin{1};
object.Grid1=x;
object.Grid1Uniform=true;
object.Grid2=y;
object.Grid2Uniform=true;
object.Data=z./count;
object.LimitIndex1='all';
object.LimitIndex2='all';
object.Source='Object merge';
%concealProperty(object,'SourceFormat','SourceRecord');
object.ObjectHistory={}; % start fresh

end