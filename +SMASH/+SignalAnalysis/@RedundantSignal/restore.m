function object=restore(data)

object=SMASH.SignalAnalysis.RedundantSignal();

name=fieldnames(data);
for k=1:numel(name)
    if isprop(object,name{k})
        object.(name{k})=data.(name{k});
    end
end

end