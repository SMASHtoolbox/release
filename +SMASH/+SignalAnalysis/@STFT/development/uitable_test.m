% UNDER CONSTRUCTION
function uitable_test(data,label)

% handle input
if (nargin<1) || isempty(data)
    data=randn(100,4);
    temp=1:size(data,1);
    data(:,1)=temp(:);
end
columns=size(data,2);

if (nargin<2) || isempty(label);
    label=cell(1,columns);
    for m=1:columns
        label{m}=sprintf('Column %d',m);
    end
end
label{1}='Row';

% size testing
fig=figure;
h=uicontrol('Style','text');
columnwidth=cell(1,columns);
fulllabel='';
for m=1:columns    
    temp=sprintf('%s   ',label{m});
    fulllabel=[fulllabel temp];
    set(h,'String',temp);
    extent=get(h,'Extent');
    columnwidth{m}=extent(3);
    rowheight=extent(4);
end
delete(h);
%fulllabel(1:5)=' ';

t=uitable('Parent',fig,'Data',data,...
    'RowName','','ColumnName','',...
    'ColumnWidth',columnwidth);
set(t,'ColumnEdit',true);
format={'char'};
set(t,'ColumnFormat',repmat(format,[1 columns]));
position=get(t,'Position');
extent=get(t,'Extent');
position(3)=extent(3);
position(4)=10*rowheight;
%position(3)=position(3)+25; % make room for the vertical slider
set(t,'Position',position);
set(t,'CellEditCallback',@cellEditCallback);


y0=position(2)+position(4);
h=uicontrol('Style','text','String',fulllabel);
extent=get(h,'Extent');
position=[position(1) y0 extent(3) extent(4)];
set(h,'Position',position,...
    'BackgroundColor',get(fig,'Color'));

end

function cellEditCallback(source,eventdata)

new=sscanf(eventdata.EditData,'%g',1);
if isempty(new)
    return
end

new=sprintf('%+#g',new);
%data=source.Data;


end
