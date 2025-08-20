% restore Restore object from an archive

function object=restore(data)

object=SMASH.SignalAnalysis.STFT([],1:10);

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        object.(name{n})=data.(name{n});
    end
end

end