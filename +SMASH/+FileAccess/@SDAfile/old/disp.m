function disp(object)

tab=repmat(' ',[1 3]);

fprintf('%s object\n',class(object));
fprintf('\n');

fprintf('Properties:\n');
name=properties(object);
name=sort(name);
L=max(cellfun(@numel,name));
format=[tab '%' sprintf('%ds : ',L);];
for n=1:numel(name)
    fprintf(format,name{n});
    value=object.(name{n});
    if isnumeric(value) || islogical(value)
        if isscalar(value)           
            fprintf('%g',value);
        elseif numel(value)==2
            fprintf('[%g %g]',value(:));
        else
            temp=size(value);
            temp=sprintf('%dx',temp);
            temp=temp(1:end-1);
            fprintf('[%s %s]',temp,class(value));            
        end
    elseif ischar(value)
        if size(value,1)>1
            temp=size(value);
            temp=sprintf('%dx',temp);
            temp=temp(1:end-1);
            fprintf('[%s %s]',temp,class(value))
        else
            fprintf('''%s''',value);
        end
    elseif iscell(value)
        temp=size(value);
        temp=sprintf('%dx',temp);
        temp=temp(1:end-1);
        fprintf('[%s %s]',temp,class(value));
    else
        fprintf('[%s]',class(value));
    end
    fprintf('\n');
end
fprintf('\n');

fprintf('Methods:\n');
name=methods(object);
L=max(cellfun(@numel,name));
col=floor(min(80/L));
format=sprintf('%%-%ds ',L);
format=repmat(format,[1 col]);
format=[tab format];
while numel(name)>0
    N=min([col numel(name)]);
    fprintf(format,name{1:N});
    fprintf('\n');
    name=name(col+1:end);
end
fprintf('\n');

end