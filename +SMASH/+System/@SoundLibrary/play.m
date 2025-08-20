function play(object,name,varargin)

match=false;
N=numel(object.Name);
for n=1:N
    if strcmp(name,object.Name{n})
        source=object.Data(n);
        match=true;
    end
end
assert(match,'ERROR: unrecognized sound name');

play(source);


end