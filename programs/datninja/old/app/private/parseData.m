
function [out,format]=parseData(in,format)

% verify numeric input
in=strtrim(in);
[out,~,~,next]=sscanf(in,'%g',1);
if isempty(out)
    return
end
in=in(1:next-1);

% update format
new=0;
start=false;
while numel(in) > 0
    switch lower(in(1))
        case {'e' 'd'}
            break
        case {'1' '2' '3' '4' '5' '6' '7' '8' '9'}
            new=new+1;
            start=true;
        case '0'
            if start
                new=new+1;
            end
    end
    in=in(2:end);
end

for k=1:numel(format)
    old=sscanf(format(k:end),'%d',1);
    if ~isempty(old)        
        break
    end
end

if new > old
    format=sprintf('%%#+.%dg',new);
end

end