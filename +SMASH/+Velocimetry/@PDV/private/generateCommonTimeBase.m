% place channels on common time base
function [object,N]=generateCommonTimeBase(object)

for n=1:object.NumberChannels
    temp=object.Channel{n}.Measurement;    
    if n == 1
        junk=SMASH.SignalAnalysis.SignalGroup(temp);
    else
        junk=gather(junk,temp);
    end
end
N=numel(junk.Grid);

for n=1:object.NumberChannels
    object.Channel{n}.Measurement=reset(...
        object.Channel{n}.Measurement,junk.Grid,junk.Data(:,n));
end

end