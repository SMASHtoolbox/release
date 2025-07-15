% remove Remove basis function
%
% This method removes an existing basis function from a Curve object.
% Functions are usually referred to by their addition order.
%    >> object=remove(object,index);
% An object can be entirely emptied by requesting the removal of all
% functions.
%    >> object=remove(object,'all');
%
% See also Curve, add, edit, summarize
%

%
% created November 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=remove(object,index)

% handle input
assert(nargin==2,'ERROR: insufficient input');
if strcmpi(index,'all')
    object.Basis={};
    object.Parameter={};
    object.Bound={};
    object.Scale={};
    object.FixScale={};
    return
end

assert(isnumeric(index) & (numel(index)>0),'ERROR: invalid index');
index=sort(index);
while numel(index)>0
    current=index(1);
    Nbasis=numel(object.Basis);
    k=[1:(current-1) (current+1):Nbasis];
    object.Basis=object.Basis(k);
    object.Parameter=object.Param(k);   
    object.Bound=object.Bound(k);
    object.Scale=object.Scale(k);
    object.FixScale=object.FixScale(k);
    index=index-1;
    index=index(2:end);
end

object.FitComplete=false;

end