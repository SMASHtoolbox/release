% read Read LUNA scan from a file
%
% This file reads LUNA scans from a file.
%     >> object=read(object,filename,[record]);
% A read operation is performed automatically at object creation. 
%

function object=read(object,filename,record)

% manage input
if (nargin<2) || isempty(filename)
   [filename,pathname]=uigetfile({'*.*','All files'},...
       'Select LUNA file');
   if isnumeric(filename)
       error('ERROR: source file not read');
   end
   filename=fullfile(pathname,filename);
end

if (nargin<3)
    record='';
end

% read file based on extension
assert(exist(filename,'file')==2,'ERROR: source file does not exist');

[~,shortname,extension]=fileparts(filename);
switch lower(extension)
    case '.sda'
        previous=SMASH.FileAccess.readFile(filename,'sda',record);
        if isstruct(previous)
            previous=SMASH.FileAccess.LUNA(previous);
        else
            assert(isa(previous,'SMASH.FileAccess.LUNA'),...
                'ERROR: requested record is not a LUNA object');
        end
        object=previous;
        return
    case '.obr'
        [time,signal,header]=read_OBR(filename);
    otherwise
        [time,signal,header]=read_text(filename);
end
object.SourceFile=[shortname extension];
object.FileHeader=header;
object.Time=single(time(:));
object.LinearAmplitude=single(signal(:));
object.IsModified=false;
object.GroupIndex=object.FileHeader.GroupIndex;

% convert from /mm to /ns
persistent c0
if isempty(c0)
    c0=SMASH.Reference.PhysicalConstant('c0','SI');
end
object.LinearAmplitude=object.LinearAmplitude...
    *1000*(c0/object.FileHeader.GroupIndex)/1e9;

end
