% MERGE Merge Signal objects into a single object
%
% This method merges mutiple Signal objects into a single object.
%    >> new=merge(object1,object2,...);
% The new object Grid is determined by the outermost points of the source
% object, spaced by the smallest source grid spacing.  Source objects are
% added to this new grid sequentially, averaging overlapping information as
% needed.  Points that do not correspond to any source object are assigned
% to NaN.
%
% Merged objects inherit most of their properties from the first source
% object, though Grid, Data, and LimitIndex are obviously changed in the
% process.  The object Source is updated to reflect this change and the
% ObjectHistory is reset.
%
% See also Signal
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised March 27, 2015 by Daniel Dolan
%   -overlapping information is now averaged
function object=merge(varargin)

assert(nargin>1,'ERROR: at least two objects needed')

[left,right,dx]=deal(nan(nargin,1));
for n=1:nargin  
    assert(isa(varargin{n},'SMASH.SignalAnalysis.Signal'),...
        'ERROR: non-Signal input detected')
    if ~varargin{n}.GridUniform
        varargin{n}=regrid(varargin{n});
    end
    temp=varargin{n}.Grid;
    left(n)=min(temp);
    right(n)=max(temp);
    dx(n)=(right(n)-left(n))/(numel(temp)-1);
end
width=max(right)-min(left);
dx=min(dx);
N=1+ceil(width/dx);

x=linspace(min(left),max(right),N);
x=x(:);
y=nan(size(x));
valid=zeros(size(x));
for n=1:nargin
    xtemp=varargin{n}.Grid;
    keep=(x>=left(n)) & (x<=right(n));
    ytemp=y(keep);
    ytemp(isnan(ytemp))=0;
    y(keep)=ytemp+interp1(xtemp,varargin{n}.Data,x(keep));
    valid=valid+keep;
end
keep=(valid>0);
y(keep)=y(keep)./(valid(keep));

object=varargin{1};
object.Grid=x;
object.GridUniform=true;
object.Data=y;
object.LimitIndex='all';
object.Source='Object merge';
%object=concealProperty(object,'SourceFormat','SourceRecord');
object.ObjectHistory={}; % start fresh

end