% SCALE Scale Grid array
%
% This method scales the Grid in a SignalGroup object by a specifed amount.
%    >> object=scale(object,scale);
%
% See also SignalGroup, shift
%

%
% created November 24, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=scale(object,value)

% handle input
if (nargin<2) || isempty(value)
    error('ERROR: scale value must be specified');
elseif numel(value)==object.NumberSignals
    % do nothing
elseif numel(value)==1
    value=repmat(value,[1 object.NumberSignals]);
else
    error('ERROR: invalid number of scale values');
end

% apply scaling
new=cell(1,object.NumberSignals);
for n=1:object.NumberSignals
    new{n}=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));
    new{n}=scale(new{n},value(n));
end

[new{:}]=register(new{:});
object.Grid=new{1}.Grid;
object.Data=nan(numel(object.Grid),object.NumberSignals);
for n=1:object.NumberSignals
    object.Data(:,n)=new{n}.Data;
end

object=updateHistory(object);

end