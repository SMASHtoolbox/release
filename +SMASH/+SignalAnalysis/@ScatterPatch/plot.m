function varargout=plot(object,mode)

%
if (nargin < 2) || isempty(mode)
    mode='mapdata';
else
    assert(ischar(mode),'ERROR: invalid ');
end

new=SMASH.MUI.Figure('Visible','off');
switch lower(mode)
    case {'rawdata' 'mapdata'}        
        if strcmpi(mode,'rawdata')            
            data=object.RawData;
        else            
            data=object.MappedData;
        end            
        area=data(:,3).*data(:,4);
        color=10*log10(max(area)./area);              
        keep=logical(data(:,6));
        color(~keep)=nan;
        data=transpose(data);
        columns=size(data,2);
        [x,y,z]=deal(nan(4,columns));
        x(1,:)=data(1,:)-data(3,:);
        x(2,:)=data(1,:)+data(3,:);
        x(3,:)=data(1,:)+data(3,:);
        x(4,:)=data(1,:)-data(3,:);
        y(1,:)=data(2,:)-data(4,:);
        y(2,:)=data(2,:)-data(4,:);
        y(3,:)=data(2,:)+data(4,:);
        y(4,:)=data(2,:)+data(4,:);                
        for k=1:4
            z(k,:)=color;
        end        
        patch(x,y,z,color,'LineStyle','none')
        xlabel(object.HorizontalLabel);
        ylabel(object.VerticalLabel);
        colormap(object.Colormap);
        hc=colorbar();
        ylabel(hc,'Quality (dB)');
        bound(2)=ceil(max(color));
        bound(1)=floor(min(color));
        caxis(bound);
        caxis('auto'); % added by NPB as a quick fix - likely want to change this
    case 'result'
        assert(~isempty(object.Result),'ERROR: no processing result');
        data=object.Result;
        M=numel(data);
        color=lines(M);
        for m=1:M
            x=data{m}(:,1);
            y=data{m}(:,2);
            subplot(2,1,1);
            line(x,y,'Color',color(m,:));
            dy=data{m}(:,3);
            subplot(2,1,2);
            line(x,dy,'Color',color(m,:));
        end
        ha=findobj(gcf,'Type','axes');
        set(ha,'Box','on');
end
box on;
figure(new.Handle);

if nargout > 0
    varargout{1}=new;
end

end
