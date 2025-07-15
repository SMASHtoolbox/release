function table=generateTable(object)

[value,width,location]=report(object);
switch object.Mode
    case 'x'
        xA=location(:);
        yA=value(:);
        xB=[xA; xA(end:-1:1)];
        yB=[yA+width; yA(end:-1:1)-width(end:-1:1)];
    case 'y'
        xA=value(:);
        yA=location(:);
        xB=[xA+width; xA(end:-1:1)-width(end:-1:1)];
        yB=[yA; yA(end:-1:1)];
end

if numel(xB) > 0
    xB(end+1)=xB(1);
    yB(end+1)=yB(1);
end

table{1}=[xA(:) yA(:)];
table{2}=[xB(:) yB(:)];

end