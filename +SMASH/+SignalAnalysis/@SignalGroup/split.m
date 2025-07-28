% SPLIT Divide SignalGroup into Signal objects
%
% This method breaks up a SignalGroup object into a collection of Signal
% objects.
%    [object1,object2,...]=split(object)
%
% Specific signals can be extracted by passing in index array.  For
% example:
%    [object3,object2]=split(object,[3 2]);
% extracts the second and third signal in *reverse* order.  The output
% arguments follow the ordering specified by the index array.
%
% See also SignalGroup, gather
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories)
% modified May 11, 2018  by Daniel Dolan
%    -Specific signals now accessible by index
%

function varargout=split(object,index)

% manage input
valid=1:object.NumberSignals;
if (nargin < 2) || isempty(index) || strcmpi(index,'all')
    index=valid;
else
    errmsg='ERROR: invalid index value';
    assert(isnumeric(index),errmsg);
    for n=1:numel(index)
        assert(any(index(n) == valid),errmsg);
    end
end

N=numel(index);
assert(nargout <= N,...
    'ERROR: too many outputs requested');
varargout=cell(1,N);

bound=limit(object);
bound=[min(bound) max(bound)];
if numel(object.Legend) == 1
    object.Legend = repmat(object.Legend, 1, object.NumberSignals);
end
for n=1:N
    k=index(n);
    varargout{n}=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,k));
    varargout{n}=limit(varargout{n},bound);
    varargout{n}.Source='SignalGroup split';    
    varargout{n}.GridLabel=object.GridLabel;
    varargout{n}.DataLabel=object.Legend{k};
end

end