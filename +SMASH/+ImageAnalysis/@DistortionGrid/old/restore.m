% restore Restore Image object from an archive

function object=restore(data)

object=SMASH.ImageAnalysis.Distortion([],[],NaN);

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        object.(name{n})=data.(name{n});
    end
end

end