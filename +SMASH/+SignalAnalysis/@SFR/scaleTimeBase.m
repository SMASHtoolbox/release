% scaleTimeBase Scale time base
%
% This method scales the measurement time base by a constant value.
%    scaleTimeBase(object,value);
% The input "value" must be a number > 0.  Omitting this value or passing a
% value of 1 leaves the object unchanged.
%
% All time bases derived from the measurement are automatically scaled.
% Frequency quantities are inversely scaled for consistency, and unit
% definitions are automatically cleared to avoid confusion.
%
% See also SFR, cropTime, shiftTime
%
function scaleTimeBase(object,value)

% manage input
if (nargin < 2) || isempty(value) || (value == 1)
    fprintf('No scaling required\n');
    return
else
    assert(testNumber(value) && (value > 0),...
        'ERROR: invalid time scaling');
end

% apply scaling
UnitReset=false;
for k=1:numel(object)   
    units=object(k).Units;
    if ~isempty(units.Time) || ~isempty(units.Frequency)
        UnitReset=true;
    end
    object(k).Units=struct('Time','','Frequency','');   
    object(k).SampleRate=object(k).SampleRate/value;
    object(k).FrequencyBand=object(k).FrequencyBand/value;
    object(k).PrivateRiseTime=object(k).PrivateRiseTime*value;
    object(k).PrivateFullTime=object(k).PrivateFullTime*value;
    if ~isempty(object(k).PrivateAmplitude)
        object(k).PrivateAmplitude(:,1)=object(k).PrivateAmplitude(:,1)*value;
    end
    object(k).Preview=applyScale(object(k).Preview,[1 -1 -1 0],value);
    source=object(k).Selection;
    object(k).Selection=updateSelection(source,value);
    object(k).Reduction=applyScale(object(k).Reduction,[1 -1 -1 0],value);
end

if UnitReset
    warning('Unit labels were reset by time scaling');
end

end

%%
function record=applyScale(record,flag,value)

if isempty(record)
    return
end

for n=1:numel(record)
    record(n).FrequencyBand=record(n).FrequencyBand/value;
    record(n).EffectiveTime=record(n).EffectiveTime*value;
    record(n).FullTime=record(n).FullTime*value;
    record(n).RiseTime=record(n).RiseTime*value;
    record(n).SampleRate=record(n).SampleRate/value;
    record(n).StepTime=record(n).StepTime*value;
    for column=1:size(record(n).Data,2)
        if flag(column) == 1
            record(n).Data(:,column)=record(n).Data(:,column)*value;
        elseif flag(column) == -1
            record(n).Data(:,column)=record(n).Data(:,column)/value;
        end
    end
end

end

function source=updateSelection(source,value)

if isempty(source)
    return
end

for n=1:numel(source)
    if ~isempty(source(n).DefaultWidth)
        source(n).DefaultWidth=source(n).DefaultWidth/value;
    end
    data=source(n).Data;
    data(:,1)=data(:,1)*value;
    data(:,2:3)=data(:,2:3)/value;
    source(n)=define(source(n),data);
end

end