% probe Probe database file
%
% This method probes an exisiting database file.  When called with no
% outputs:
%    >> probe(object);
% the method prints a short summary of the database's contents.  More
% complete information is obtained with outputs.
%    >> [parameter,header,body]=probe(object);
%
% See also SimpleDatabase, read, view
%

%
% created May 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=probe(object)

% open file and read header
fid=fopen(object.Filename,'r');
assert(fid>2,'ERROR: unable to read database file');

header={};
header{end+1}=fgetl(fid); % identification line
index=regexp(header{end},'# SimpleDatabase');
assert(~isempty(index) & index==1,'ERROR: file does not contain a SimpleDatabase');
header{end+1}=fgetl(fid); % date
header{end+1}=fgetl(fid);
Nrecords=readValue(header{end}); 
Nrecords=sscanf(Nrecords,'%d');
header{end+1}=fgetl(fid);
Nfields=readValue(header{end});
Nfields=sscanf(Nfields,'%d');
[label,name,datatype]=deal(cell(Nfields,1));
for n=1:Nfields
    header{end+1}=fgetl(fid);     %#ok<AGROW>
    label{n}=strtrim(header{end}(2:end)); % omit # sign
    index=regexp(label{n},':');
    index=index(1);
    datatype{n}=sscanf(label{n}(index+1:end),'%s');
    name{n}=sscanf(label{n}(1:index-1),'%s',1);
    label{n}=label{n}(1:index);
end

% collect header items into parameter structure
param.NumberRecords=Nrecords;
param.NumberFields=Nfields;
param.Label=label;
param.Name=name;
param.DataType=datatype;

% read the data and close file
body=fscanf(fid,'%c');
start=regexp(body,label{1});
stop=start(2:end)-1;
stop(end+1)=numel(body);
record=cell(Nrecords,1);
for m=1:Nrecords
    record{m}=body(start(m):stop(m));        
end
fclose(fid);

% handle output
if nargout==0
    [~,shortname,ext]=fileparts(object.Filename);
    fprintf('Summary of %s\n',[shortname ext]);
    disp(param);
else
    varargout{1}=param;
    varargout{2}=sprintf('%s\n',header{:});
    varargout{3}=body;
end

end

function value=readValue(str)

temp=regexp(str,':');
temp=temp(end);
value=str(temp+1:end);

end