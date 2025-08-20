%    object=findRange(object,source)

function object=findRange(object,varargin)

assert(~all(object.FixRange),'ERROR: all measurement ranges are fixed');

% manage 
M=object.NumberSignals;
try
    source=SMASH.SignalAnalysis.SignalGroup(varargin{:});
catch ME
    throwAsCaller(ME);
end
assert(source.NumberSignals == M,'ERROR: invalid number of calibration signals');

for m=1:M
    if object.FixRange(m)
        continue
    end
    temp=object.Measurement.Data(:,m);
    object.Range(m,1)=min(temp);
    object.Range(m,2)=max(temp);
end

end