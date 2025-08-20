function varargout=view(object)

fig=figure;
ha=axes('Parent',fig,'Box','on','XTick',[]);
switch object.Direction
    case 'vertical'
        ha.XTickLabel='';
        ylabel(object.Label);
    case 'horizontal'
        ha.YTickLabel='';    
        xlabel(object.Label);
end

start=0;
for m=1:numel(object.Group)
    center=[start inf];
    % generate bars
    for n=1:size(object.Group(m).Table,1)
        stop=start+1;
        switch object.Direction
            case 'vertical'
                x=[start stop stop start];
                y=sort(object.Group(m).Table(n,:));
                y=[y(1) y(1) y(2) y(2)];
            case 'horizontal'
                x=sort(object.Group(m).Table(n,:));
                x=[x(1) x(1) x(2) x(2)];
                y=[start stop stop start];
        end
        patch(x,y,object.Color(n,:));
        start=start+1;
    end
    % generate label
    center(2)=stop;
    center=mean(center);    
    switch object.Direction
        case 'vertical'
            bound=ylim;
            text(center,bound(1),bound(1),object.Group(m).Label,...
                'HorizontalAlignment','center','VerticalAlignment','top');
        case 'horizontal'
            bound=xlim;
            text(bound(1),center,bound(1),object.Group(m).Label,...
                'HorizontalAlignment','right','VerticalAlignment','center');                        
    end
    % prepare for next gropu
    if m < numel(object.Group)
        start=start+1;
    end
end

axis auto
ht=findobj(ha,'Type','text');
for k=1:numel(ht)
    switch object.Direction
        case 'vertical'
            bound=ylim;
            ht(k).Position(2)=bound(1);
        case 'horizontal'
            bound=xlim;
            ht(k).Position(1)=bound(1);
    end
    ht(k).Units='normalized';
end

if nargout > 0
    varargout{1}=ha;
end

end