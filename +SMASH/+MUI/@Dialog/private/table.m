function varargout=table(object,label,minwidth,rows)

% handle input
if (nargin<2) || isempty(label)
    label={' Column 1 ' ' Column 2 '};
end
assert(iscell(label),'ERROR: label input must be a cell array');
columns=numel(label);

if (nargin<3) || isempty(minwidth)
    minwidth=0;
end
assert(isnumeric(minwidth),'ERROR: invalid minwidth');
if numel(minwidth)==1
    minwidth=repmat(minwidth,[1 columns]);
end
assert(numel(minwidth)==columns,'ERROR: inconsistent input sizes');

if (nargin<4) || isempty(rows)
    rows=10;
end

% error checking
verify(object);

% create block
h=nan(1,columns+1);
columnwidth=cell(1,columns);
totalwidth=0;
for n=1:columns
    Ndummy=max(numel(label{n}),minwidth(n));
    dummy=max(numel(label{n}),Ndummy);
    dummy=repmat('M',[1 dummy]);
    h(n)=local_uicontrol(object,'Style','text','String',dummy,...
        'HorizontalAlignment','left');
    position=get(h(n),'Position');
    if n==1
        x0=position(1);
        Ly=position(4);
    end
    position(1)=x0;
    set(h(n),'Position',position);
    columnwidth{n}=position(3);
    x0=x0+columnwidth{n};
    set(h(n),'String',label{n});   
    object.Controls(end+1)=h(n);
    totalwidth=totalwidth+columnwidth{n};
end
pushup(object,columns,object.VerticalGap+Ly);
position=get(h(1),'Position');
x0=position(1);

h(end)=uitable('Parent',object.Handle,'RowName','','ColumnName','',...
    'ColumnWidth',columnwidth,'Data',cell(rows,columns),...
    'ColumnEditable',true);
position(1)=x0;
position(3)=totalwidth+columns; % add an extra pixel for each row
extent=get(h(end),'Extent');
position(4)=extent(4);
set(h(end),'Position',position);
object.pushup;
object.Controls(end+1)=h(end);

% leave room for vertical slider
ht=uicontrol('Parent',object.Handle,'Style','slider');
position=get(ht,'Position');
SliderThickness=position(4);
position=get(h(end),'Position');
position(3)=position(3)+SliderThickness*1.5;
set(h(end),'Position',position);
delete(ht);

% create empty cells
%data=cell(rows,columns);
%set(h(end),'Data',data);

% automatically store current indices
setappdata(h(end),'CurrentCell',[1 1]);
set(h(end),'CellSelectionCallback',@selectCell);
    function selectCell(~,EventData)
        setappdata(h(end),'CurrentCell',EventData.Indices);
    end

% update dialog size
object.make_room;

% handle output
if nargout>=1
    varargout{1}=h;
end

if nargout>=2
    varargout{2}=minwidth;
end

end