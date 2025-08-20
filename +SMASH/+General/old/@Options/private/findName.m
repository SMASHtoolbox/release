function index=findName(list,name)

index=[];
for k=1:numel(list)
    if strcmp(list{k},name)
        index=k;
        return
    end
end

end