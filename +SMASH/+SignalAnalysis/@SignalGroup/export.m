% EXPORT Export SignalGroup to a basic data file
%
% This method exports a SignalGroup object to a basic data file, recording
% only the Grid/Data arrays in the limited region.
%    >> export(object,filename); % typical file extensions: *.txt, *.dat, *.out, ...
% By default, Signal objects are exported to a text file using the 'column'
% format.  


%If the export file has the extension *.sda, the object is
% exported to a record inside a Sandia Data Archive and a label is
% required.
%    >> export(object,filename,label); % *.sda file extension
%
% See also SignalGroup, store
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function export(object,filename,mode)

% handle input
if nargin<2
    filename='';
end

if (nargin<3) || isempty(mode)   
    mode='create';
end

% get data from object
[x,y]=limit(object);
%header=sprintf('%s %s',object.GridLabel,object.DataLabel);

% place data into file
[~,~,ext]=fileparts(filename);
if strcmpi(ext,'.pff')
    data=struct();
    data.Grid={object.Grid};
    data.GridLabel={object.GridLabel};
    data.Vector={object.Data}; % is this correct?
    data.VectorLabel={object.DataLabel};   
    data.Type='SignalGroup export';
    data.Title=object.Name;
    archive=SMASH.FileAccess.PFFfile(filename);
    write(archive,data,mode);
else
    table=[x y];  
    format=repmat('%#+e\t',[1 object.NumberSignals]);
    format=['%#+e\t' format(1:end-2) '\n'];
    header{1}=sprintf('SignalGroup export on %s',datestr(now));    
    header{2}=sprintf('column format: grid');
    header{2}=[header{2} sprintf(' data%d',1:object.NumberSignals)];
    SMASH.FileAccess.writeFile(filename,table,format,header);    
end

end