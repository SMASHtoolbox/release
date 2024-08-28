function index=chooseIndex(object)

commandwindow();
fprintf('Current browser tabs:\n');
valid=1:numel(object.Tab);
for n=valid
    fprintf('   %d : %s\n',n,object.Tab(n).Name);
end
while true
    index=input('Choose index or type "quit": ','s');
    if strcmpi(index,'quit')
        index=[];
        return
    end
    index=sscanf(index,'%d',1);
    if isempty(index)
        continue
    elseif any(index == valid)
        break
    end
end

end