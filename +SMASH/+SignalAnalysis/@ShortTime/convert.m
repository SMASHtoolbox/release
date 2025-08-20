function object=convert(source)

assert(isa(source,'SMASH.SignalAnalysis.Signal'),...
    'ERROR: cannot convert object to ShortTime class');

object=SMASH.SignalAnalysis.ShortTime(source.Grid,source.Data);
name=properties(source);
for n=1:numel(name)
    if strcmp(name{n},'Grid') || strcmp(name{n},'Data')
        continue
    end
    if isprop(object,name{n})
        object.(name{n})=source.(name{n});
    end    
end

end