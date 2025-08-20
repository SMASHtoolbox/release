% EXPORT Export object to a basic data file
%
% This method exports a Signal object to a basic data file, recording only
% the Grid/Data arrays in the limited region.
%    export(object,filename); % typical file extensions: *.txt, *.dat, *.out, ...
% By default, Signal objects are exported to a text file using the 'column'
% format.  Numeric entries are printed using '%#+.6e' by default, but
% custom format can be requested.
%    export(object,filename,format);
% The input "format" must follow sprintf guidelines for an individual
% number.
%
% Signal objects are exported in binary format for specific file
% extensions.
%    -Portable File Format for *.pff extensions.
%    -DIG format for *.dig extensions.
%
% See also Signal, store, sprintf
%
function export(object,filename,option)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(ischar(filename),'ERROR: invalid file name');
assert(~isempty(filename),'ERROR: invalid file name');
[~,~,extension]=fileparts(filename);

if (nargin < 3) || isempty(option)   
    option='';
end

% place data into file
[x,y]=limit(object);
if strcmpi(extension,'.pff')
    data=struct();
    data.Grid={object.Grid};
    data.GridLabel={object.GridLabel};
    data.Vector={object.Data};
    data.VectorLabel={object.DataLabel};   
    data.Type='Signal export';
    data.Title=object.Name;
    archive=SMASH.FileAccess.PFFfile(filename);
    try
        write(archive,data,mode);
    catch ME
        throwAsCaller(ME);
    end
elseif strcmpi(extension,'.dig')
    SMASH.FileAccess.writeFile(filename,object.Grid,object.Data);
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
    table=[x(:) y(:)];        
    %format='%#+.6e %#+.6e \n';
    format=[option '\t' option '\n'];
    header{1}=sprintf('Signal export on %s',datestr(now)); %#ok<TNOW1,DATST> 
    header{2}=sprintf('column format: grid data');
    SMASH.FileAccess.writeFile(filename,table,format,header);    
end

end