% restore Restore ImageGroup object from an archive

function object=restore(data)

object=SMASH.ImageAnalysis.ImageGroup([],[],NaN);   %Need to make sure I can make a blank like this.

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        object.(name{n})=data.(name{n});
    end
end

end