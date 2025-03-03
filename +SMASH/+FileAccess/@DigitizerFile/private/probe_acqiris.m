function report=probe_acqiris(filename)

report=struct();

% read header
location='/Header';
header=h5info(filename,location);
for n=1:numel(header.Attributes)
    name=header.Attributes(n).Name;
    report.(name)=h5readatt(filename,location,name);
end

location='/Header/RunParameters';
header=h5info(filename,location);
for n=1:numel(header.Attributes)
    name=header.Attributes(n).Name;
    report.(name)=h5readatt(filename,location,name);
end

% 



end