function result=verifyColumn(object,index)

result=true;

valid=1:object.Columns;
for n=1:numel(index)
    if any(index(n) == valid)
        continue
    end
    result=false;
    break
end

end