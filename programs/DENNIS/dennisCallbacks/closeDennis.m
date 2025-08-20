function closeDennis(src, event)

warning('off', 'all');

things2close = getappdata(src);
names = fieldnames(things2close);
for ii = length(names):-1:3
    deleteMe = things2close.(names{ii});
    try
        delete(deleteMe.Figure);
    catch
    end
    try
        delete(deleteMe);
    catch
    end
end

try
    delete(src);
catch
end

warning('on', 'all');

end