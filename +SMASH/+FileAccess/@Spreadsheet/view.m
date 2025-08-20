% view View worksheet data
%
% This method displays worksheet data in an interactive table.
%    view(object); % first sheet or text data
%    view(object,sheet); % specified sheet
% For Excel files, sheets can be specified by name or numeric index.
%
% See also Spreadsheet, read, extract
%

%
% created January 23, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,varargin)

try
    [data,sheet]=read(object,varargin{:});
catch ME
    throwAsCaller(ME)
end

% generate dialog box
db=SMASH.MUI.Dialog('FontSize',12);
db.Hidden=true;
db.Name='Worksheet view';
db.Handle.HandleVisibility='callback';
db.Handle.IntegerHandle='off';

[M,N]=size(data);
label=cell(1,N);
offset=double('A')-1;
width=zeros(1,N);
for n=1:N
    label{n}=char(offset+n);
    for m=1:M
        width(n)=max(width(n),numel(data{m,n}));
    end
end
width=width/sum(width);

rows=min(M,object.Height);
h=addblock(db,'table',{sheet},object.Width,rows);
set(h(end),'Data',data,'RowName','numbered',...
    'ColumnName',label,'ColumnEditable',false);
pos=getpixelposition(h(end));
width=width*pos(3)*0.90;
set(h(end),'ColumnWidth',num2cell(width));
set(h(1),'FontWeight','bold');

if nargout == 0
    locate(db,'center');
    show(db);
else   
    varargout{1}=db;
end

end