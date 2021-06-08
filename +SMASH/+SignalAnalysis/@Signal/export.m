% EXPORT Export object to a basic data file
%
% This method exports a Signal object to a basic data file, recording only
% the Grid/Data arrays in the limited region.
%    >> export(object,filename); % typical file extensions: *.txt, *.dat, *.out, ...
% By default, Signal objects are exported to a text file using the 'column'
% format.  
% Signal objects can also be exported to PFF files.
%    >> export(object,filename); %
%
% See also Signal, store
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories) 
% revised January January 27, 2015 by Daniel Dolan
%   -added PFF support
function export(object,filename,mode)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(ischar(filename),'ERROR: invalid file name');
assert(~isempty(filename),'ERROR: invalid file name');
[~,~,extension]=fileparts(filename);

if (nargin<3) || isempty(mode)   
    mode='create';
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
    write(archive,data,mode);
elseif strcmpi(extension,'.dig')
    SMASH.FileAccess.writeFile(filename,object.Grid,object.Data);
else
    table=[x(:) y(:)];        
    format='%#+.6e %#+.6e \n';
    header{1}=sprintf('Signal export on %s',datestr(now));
    header{2}=sprintf('column format: grid data');
    SMASH.FileAccess.writeFile(filename,table,format,header);    
end

end