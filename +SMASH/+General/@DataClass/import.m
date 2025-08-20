function object=import(object,data)

try
    object.Data=data.Data;
catch
    error('ERROR: unable to import data');
end

end