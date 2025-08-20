function [data,header]=read_hamamatsu(filename)

% handle input
if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.img;*.IMG','Select Hamamatsu IMG file');
    filename=[pname fname];
end

% create function handle
fid=fopen(filename,'r','ieee-le'); % little endian ordering
exitFunction=onCleanup(@() fclose(fid));

% process header
header.IM=transpose(fread(fid,2,'*char'));
header.CommentLength=fread(fid,1,'uint16');
header.ImageWidth=fread(fid,1,'uint16');
header.ImageHeight=fread(fid,1,'uint16');
header.XOffset=fread(fid,1,'uint16');
header.YOffset=fread(fid,1,'uint16');
header.FileType=fread(fid,1,'uint16');

fseek(fid,64,'bof'); % skip reserved section

header.Comment=transpose(fread(fid,header.CommentLength,'*char'));

M=header.ImageHeight;
N=header.ImageWidth;
switch header.FileType
    case 0
        data=fread(fid,M*N,'uint8');
    case 2
        data=fread(fid,M*N,'uint16');
    otherwise
        error('ERROR: invalid file type');
end
data=reshape(data,N,M);
data=transpose(data);

end