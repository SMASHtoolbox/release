% EXPORT Export SignalGroup to a basic data file
%
% This method exports a SignalGroup object to a basic data file, recording
% only the Grid/Data arrays in the limited region.
%    >> export(object,filename); % typical file extensions: *.txt, *.dat, *.out, ...
% By default, Signal objects are exported to a text file using the 'column'
% format.
%
% See also SignalGroup, store
%
function export(object,filename,option)

% handle input
if nargin<2
    filename='';
end

if (nargin<3) || isempty(option)
    option='';
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
    try
        write(archive,data,option);
    catch ME
        throwAsCaller(ME);
    end
else
    if isempty(option)
        option='%#+.6e';
    else
        try
            temp=sprintf(option,pi);
            [~,count,~,next]=sscanf(temp,'%g',1);
            assert((count == 1) && isempty(temp(next:end)));
        catch
            error('ERROR: invalid number format');
        end
    end
end
table=[x y];
format=repmat([option '\t'],[1 object.NumberSignals]);
format=[option '\t' format(1:end-2) '\n'];
header{1}=sprintf('SignalGroup export on %s',datestr(now)); %#ok<TNOW1,DATST> 
header{2}=sprintf('column format: grid');
header{2}=[header{2} sprintf(' data%d',1:object.NumberSignals)];
SMASH.FileAccess.writeFile(filename,table,format,header);

end