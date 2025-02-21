% restore Restore object from an archive

function object=restore(data)

object=SMASH.SignalAnalysis.SignalGroup([],nan(2,data.NumberSignals));
object.Legend={};
object.Color=[];

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        try %#ok<TRYNC>
            object.(name{n})=data.(name{n});
        end
    end
end

end