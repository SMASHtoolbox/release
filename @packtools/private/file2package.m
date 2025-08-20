function package=file2package(file)

[file,~,~]=fileparts(file); % remove file name
if endsWith(file,'private')
    [file,~,~]=fileparts(file);
end
package='';
while true
    [file,temp,~]=fileparts(file);    
    if temp(1) == '@'
        continue
    elseif temp(1) ~= '+'        
        break    
    end
    package=sprintf('%s.%s',temp(2:end),package);
end

assert(~isempty(package),'ERROR: invalid package name');
package=package(1:end-1);

end