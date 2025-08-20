function [signal,time,info,header]=read_yokogawa(filename)

% handle input
if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.wfm;*.WFM','Choose Yokogawa WFM file');
    filename=fullfile(pname,fname);
end

% verify file
if exist(filename,'file')~=2
    id='wfmread:FileNotFound';
    message='File error: \n \t %s \n \t does not exist!\n';
    error(id,message,filename);
end

% make sure file can be opened 
fid=fopen(filename,'rb');
if fid==-1
    id='wfmread:FileNotOpened';
    message='File error: \n \t %s \n \t cannot be opened!\n';
    error(id,message,filename);
end

% scan header for neccessary data
for n=1:2
    header=fgetl(fid);
end
[junk,count,err,next]=sscanf(header,'%s',1);
header=header(next:end);

colon=find(header==':');
comma=find(header==',');
if numel(colon)~=numel(colon)
    error('ERROR: invalid header');
else
    Nfield=numel(colon);
end
start=1;
for n=1:Nfield
    stop=colon(n)-1;
    field=sscanf(header(start:stop),'%s',1);
    field(field=='.')='_';
    start=colon(n)+1;
    stop=comma(n)-1;
    value=sscanf(header(start:stop),'%s',1);
    info.(field)=value;
    start=comma(n)+1;
end

% verify and interpret header data
list={'NR_PT','PT_O','XIN','YMU','YOF','BIT','BYT'};
for n=1:numel(list)
    if isfield(info,list{n})
        info.(list{n})=sscanf(info.(list{n}),'%g');
    else
        error('ERROR: %s missing in header',list{n});
    end
end


% read full header and binary data
fileinfo=dir(filename);
TotalBytes=fileinfo.bytes;
DataBytes=info.NR_PT*info.BYT;
HeaderBytes=TotalBytes-DataBytes;
frewind(fid);
header=fscanf(fid,'%c',HeaderBytes);
signal=fread(fid,DataBytes,'real*4');
fclose(fid);

% apply digitizer settings
signal=info.YOF+info.YMU*signal;
time=transpose(0:(info.NR_PT-1));
time=info.XIN*(time-info.PT_O);