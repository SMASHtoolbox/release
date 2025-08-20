function table=generateTable(data,target)

xb=data(1:2);
yb=data(3:4);

if all(isfinite(data))
    xm=xb; % min/max values
    ym=yb;
else
    xm=[+inf -inf];
    ym=[+inf -inf];    
    for n=1:numel(target)
        temp=findobj(target(n));
        M=numel(temp);
        if n == 1
            child=temp;
        else
            child(end+1:end+M)=temp;
        end        
    end
    for n=1:numel(child)     
        if strcmpi(child(n).Visible,'off')
            continue
        end        
        %
        try
            temp=get(child(n),'XData');
        catch
            continue
        end
        temp=temp(:);
        temp=temp(isfinite(temp));
        if isempty(temp)
            continue
        end
        xm(1)=min(xm(1),min(temp));
        xm(2)=max(xm(2),max(temp));
        %
        temp=get(child(n),'YData');
        temp=temp(:);
        temp=temp(isfinite(temp));
        if isempty(temp)
            continue
        end
        ym(1)=min(ym(1),min(temp));
        ym(2)=max(ym(2),max(temp));
    end
    if isfinite(xb(1))
        xm(1)=xb(1);
    end
    if isfinite(xb(2))
        xm(2)=xb(2);
    end
    if isfinite(yb(1))
        ym(1)=yb(1);
    end
    if isfinite(yb(2))
        ym(2)=yb(2);
    end
end

% handle x rectangle case

if all(~isfinite(yb))
    if ~isa(target(1), 'matlab.graphics.axis.Axes')
        target = get(target(1), 'Parent');
    end
    ym = ylim(target(1));
end

x=[xm(1) xm(2) xb(2) xb(2) xm(2) xm(1) xb(1) xb(1)];
y=[yb(1) yb(1) ym(1) ym(2) yb(2) yb(2) ym(2) ym(1)];

table=[x(:) y(:)];

end