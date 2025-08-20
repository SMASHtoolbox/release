function object=RestoreFile(object,filename,label)

% access archive
archive=SMASH.FileAccess.SDAfile(filename);

contents=probe(archive);
if isempty(label)
    label=contents(1).Label;
end

% read Signal entry
target=['/' label];
try
    old=h5readatt(filename,target,'Category');
    finishup=onCleanup(@() h5writeatt(filename,target,'Category',old));
catch
    error('ERROR: label not found in archive');
end

if strcmp(old,class(object))
    h5writeatt(filename,target,'Category','structure');
    archive=SMASH.FileAccess.SDAfile(filename);
    data=extract(archive,label);
    %h5writeatt(filename,target,'Category',old);
else
    error('ERROR: requested record is not a stored SignalGroup');
end

% transfer structure into array
[~,name,ext]=fileparts(filename);
data.Source=[name ext];
data.SourceRecord=label;
object=revealProperty(object,'SourceFormat','SourceRecord');

name=fieldnames(data);
for n=1:numel(name)
    if isprop(object,name{n})
        object.(name{n})=data.(name{n});
    end
end

end