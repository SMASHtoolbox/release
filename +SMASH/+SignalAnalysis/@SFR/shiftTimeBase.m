% shiftTimeBase Shift time base
%
% This method shifts the measurement time base by a constant value.
%    shiftTimeBase(object,value);
% The input "value" must be a number; the default value is 0.
%
% All time bases derived from the measurement are automatically shifted.
%
% See also SFR, cropTime, scaleTime
%
function shiftTimeBase(object,value)

% manage input
if (nargin < 2) || isempty(value)
    value=0;
else
    assert(testNumber(value),'ERROR: invalid time shift');
end

% apply shift
for k=1:numel(object)
    object(k).StartTime=object(k).StartTime+value;
    object(k).PrivateAmplitude=applyShift(object(k).PrivateAmplitude);
    for n=1:numel(object(k).Preview)
        object(k).Preview(n).Data(:,1)=object(k).Preview(n).Data(:,1)+value;
    end
    object(k).Preview=applyShift(object(k).Preview);
    source=object(k).Selection;
    object(k).Selection=updateSelection(source,value);
    object(k).Reduction=applyShift(object(k).Reduction);   
end
    function data=applyShift(data)
        for mm=1:numel(data)
            data(mm).Data(:,1)=data(mm).Data(:,1)+value;
        end        
    end
end

%%
function source=updateSelection(source,value)

if isempty(source)
    return
end

for n=1:numel(source)
    data(:,1)=data(:,1)+value;
    source(n)=define(source(n),data);
end

end
