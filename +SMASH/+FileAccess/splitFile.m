% splitFile Split a file into a set of SDA files
%
% This function divides a file into set of SDA files.  It is intended for
% data transmission with maximum file size limits (such as email).  To
% split a file, type the following command.
%    >> splitFile(original,bytes);
% The first input specifies the original file, which is not altered in any
% way.  The split files are named after the original file from which they
% are created.  For example, a source file name "mydata" is split into
% files "mydata__file1.sda", "mydata__file2.sda", and so forth.
%
% The number of split files is determined by the original file size and the
% second input argument of this function.  The number of bytes can be
% specified as a number or a string containg a number and size unit.
%    >> splitFile(original,1024);   % write 1024 bytes to each source file
%    >> splitFile(original,'1 KB'); % write 1 kilobyte to each source file
%    >> splitFile(original,'2 MB'); % write 2 megabytes to each source file
% Valid size units are 'KB','MB', and 'GB' (case insensitive).  Due to
% overhead in the SDA format, split files will always be somewhat larger
% than the specified size.  This overhead is on the order of tens of
% kilobytes.
%
% See also SMASH.FileAccess, mergeSplits
%

%
% created October 20, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function splitFile(filename,bytes,deflate)

% handle input
assert(nargin>=2,'ERROR: insufficient input');
if ischar(bytes)
    try
        [value,~,~,next]=sscanf(bytes,'%g',1);
        bytes=bytes(next:end);
        units=sscanf(bytes,'%s',1);
        switch lower(units)
            case 'kb'
                bytes=value*1024;
            case 'mb'
                bytes=value*1024^2;
            case 'gb'
                bytes=value*1024^3;
        end       
    catch
        error('ERROR: invalid bytes specification');
    end
end
assert(SMASH.General.testNumber(bytes,'positive'),...
    'ERROR: invalid bytes specification');

if (nargin<3) || isempty(deflate)
    deflate=0;
end
assert(any(deflate==0:9),'ERROR: invalid deflate setting');

% investigate file
temp=dir(filename);
assert(numel(temp)==1,'ERROR: invalid file specification');
filesize=temp.bytes;
N=ceil(filesize/bytes);
format=sprintf('__file%%%dd.sda',ceil(log10(N)));

[pathname,shortname,ext] = fileparts(filename);
if isempty(pathname)
    pathname=pwd;
end
target=cell(1,N);
ShortName=target;
for k=1:N
    temp=sprintf(format,k);
    temp=[shortname ext temp]; %#ok<AGROW>
    target{k}=fullfile(pathname,temp);    
    assert(~exist(target{k},'file'),'ERROR: split file already exists');
    ShortName{k}=temp;
end

% split file into SDA files
fid=fopen(filename,'r');
finishup = onCleanup(@() fclose(fid));
data=struct('Bytes',[],'OriginalName','','SplitFiles','');
data.OriginalName=[shortname ext];
data.SplitFiles=ShortName;
for k=1:N
    archive=SMASH.FileAccess.SDAfile(target{k});
    data.Bytes=uint8(fread(fid,bytes,'uint8'));    
    description=sprintf('File %d of %d',k,N);
    insert(archive,'split file',data,description,deflate);    
    h5writeatt(archive.ArchiveFile,'/split file','RecordType','split');
    archive.Writable=false;
end

end