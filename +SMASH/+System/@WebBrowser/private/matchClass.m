function result=matchClass(root,pattern)

result={};
tunnel(root);
    function tunnel(current)
        temp=current.getClass();
        if any(regexpi(char(temp),pattern))
            result{end+1}=current;
        end       
        for k=1:current.getComponentCount()
            child=current.getComponent(k-1);
            tunnel(child);
        end
    end

end