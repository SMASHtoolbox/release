% SHIFT Shift Grid array
%
% This method shiftes the Grid in a SignalGroup object by a specifed
% amount.
%    >> object=shift(object,value);
%
% See also SignalGroup, scale
%

%
% created October 4, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function object=shift(object,value)

% handle input
if (nargin<2) || isempty(value)
    error('ERROR: shift value must be specified');
elseif numel(value)==object.NumberSignals
    % do nothing
elseif numel(value)==1
    value=repmat(value,[1 object.NumberSignals]);
else
    error('ERROR: invalid number of shift values');
end

% apply shift
new=cell(1,object.NumberSignals);
for n=1:object.NumberSignals
    new{n}=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));
    new{n}=shift(new{n},value(n));
end

[new{:}]=register(new{:});
object.Grid=new{1}.Grid;
object.Data=nan(numel(object.Grid),object.NumberSignals);
for n=1:object.NumberSignals
    object.Data(:,n)=new{n}.Data;
end

object=updateHistory(object);

end