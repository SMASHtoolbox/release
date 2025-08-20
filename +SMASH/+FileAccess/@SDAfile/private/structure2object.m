function object=structure2object(data,ClassName)

% try to restore object
object=[];
if exist(ClassName,'class')    
    temp=meta.class.fromName(ClassName);
    found=false;
    for n=1:numel(temp.MethodList)
        if strcmp(temp.MethodList(n).Name,'restore')
            found=true;
            break
        end
    end    
    done=false;
    if found
        try
            command=sprintf('%s.restore',ClassName);
            object=feval(command,data);
            done=true;
        catch
        end            
    end
    if ~done
        message={};
        message{end+1}=sprintf('The "%s" class does not provide a valid restore method.',ClassName);
        message{end+1}='   -Private and protected data may be lost.';
        message{end+1}='   -Restored object may behave in unexpected ways.';
        warning('SDA:restore','%s\n',message{:});
        object=feval(ClassName);
        for n=1:numel(temp.PropertyList)
            name=temp.PropertyList(n).Name;
            try
                object.(name)=data.(name);
            catch
            end
        end
    end           
% elseif exist('packtools','class')
%     [package,name]=packtools.decompose(ClassName);
%     if numel(package) > 0
%         temp=packtools.search(package{1},name);
%         if numel(temp) >= 0
%             fprintf('The "%s" class was not found--using "%s" instead\n',...
%                 ClassName,temp{1});
%             object=structure2object(data,temp{1});
%             return
%         end
%     end
end

if isempty(object)
    message={};
    message{end+1}='Unable to recreate stored object';
    message{end+1}='Returning data as a structure';
    warning('SDA:restore','%s\n',message{:});
    object=data;    
end

end