function summarize(object)

for n=1:numel(object.Group)
    name=object.Group(n).Label;
    if ischar(name)
        name={name};
    end
    fprintf('%s\n',name{:});
    disp(object.Group(n).Table);
end

end