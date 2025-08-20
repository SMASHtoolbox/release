% matchStructure Case-insensitive assignment on an existing structure
%
%     >> data=matchStructure(data,name,value);

function data=matchStructure(data,name,value)

list=fieldnames(data);
for k=1:numel(list)
    if strcmpi(name,list{k})
        data.(list{k})=value;
        return
    end
end

error('ERROR: unable to match field name');

end