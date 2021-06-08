
function [func,info]=read_winspec(filename)

if (nargin<1) || isempty(filename)
    choices{1,1}='*.spe;*.SPE';
    choices{1,2}='WinSpec files (*.spe)';
    choices{2,1}='*.*';
    choices{2,2}='All files (*.*)';
    [filename,pathname]=uigetfile(choices,'Select data file');
    filename=fullfile(pathname,filename);
end

assert(exist(filename,'file')==2,'ERROR: invalid file name');
fp=fopen(filename,'rb');

% info from the header
fread(fp,1,'int16');  % CCD x dimension
fseek(fp,42,'bof');
faccount=fread(fp,1,'int16'); % Actual image x dimension
fseek(fp,108,'bof');
datatype=fread(fp,1,'int16'); % Data type
fseek(fp,656,'bof');
stripe=fread(fp,1,'int16'); % Image y dimension

fseek(fp,4100,'bof'); % Beginning of data
switch datatype
case 0
   format='float32';
case 1
   format='int32';
case 2
   format='int16';
case 3
   format='uint16';
case 4
   format='uchar';
case 5
   format='double';
case 6
   format='uchar';
case 7
   format='uchar';
otherwise
   error('Unknown datatype');
end

func=fread(fp,[faccount,stripe],format);
fclose(fp);
%func=func';
func=transpose(func);
info.filename=filename;
