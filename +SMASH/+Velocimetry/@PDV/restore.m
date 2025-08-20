% restore Restore object from an archive

function object=restore(data)

object=SMASH.Velocimetry.PDV('-nospectrogram',data.Channel{:});

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        try %#ok<TRYNC>
            object.(name{n})=data.(name{n});
        end
    end
end

end