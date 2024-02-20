% OptronicLabDump : read dump file from Optronic spectrometer
%
% [data,header,extra,rawdata]=OptronicLabDump(filename)
%

function [data,header,extra,rawdata]=OptronicLabDump(filename)

if nargin<1
    filename=[];
end
if isempty(filename)
   [fname,pname]=uigetfile({...
           '*.txt;*.TXT','Text files (*.txt,*.TXT)';...
           '*.*','All files';...
       },'Choose Optronic dump file');
   if isnumeric(fname) % user pressed cancel
       return;
   else
       filename=[pname fname];
   end
end
if ~exist(filename,'file')
    error('File does not exist');
end

% open file and determine type
fid=fopen(filename,'r');
first=strtrim(fgets(fid));
index=strfind(first,'CALIBRATION');
if isempty(index)
    filetype='measurement';
else
    filetype='calibration';
end
newline=sprintf('\n'); % newline character

% read file blocks
ii=0;
while ~feof(fid)
    lineread=[fgetl(fid) newline];
    if all(isspace(lineread)) % empty line, ignore it
        continue
    end
    temp=strtrim(lineread);
    if all(temp=='_') % new block found
        ii=ii+1;
        block{ii}='';
    else
        block{ii}=[block{ii} sprintf('%s',lineread)];
    end
end
fclose(fid);

% remove empty blocks
Nblock=numel(block);
for ii=1:Nblock
    if isempty(block{ii})
        block(ii)=[];
    end
end

% pull off extra block at the end
extra=block{end};
block(end)=[];

% separate blocks using file type
Nblock=numel(block);
header={};
rawdata={};
switch filetype
    case 'calibration'
        for ii=1:2:Nblock
            header{end+1}=block{ii};
            rawdata{end+1}=block{ii+1};
        end
        dataformat='%g%g%g%g';
    case 'measurement'
        for ii=1:3:Nblock
            header{end+1}=[block{ii} block{ii+1}];
            rawdata{end+1}=block{ii+2};
        end
        dataformat='%g%g';
end

% convert raw data into numeric columns
data=cell(size(rawdata));
Ndata=numel(data);
Ncol=numel(dataformat);
for ii=1:Ndata
    block=rawdata{ii};
    while numel(block)>0
        [temp,count,err,next]=sscanf(block,dataformat,[Ncol inf]);
        if count>=Ncol
            data{ii}=[data{ii} temp];
        else
            next=find(block==newline,1,'first')+1;
        end
        block=block(next:end);
    end
    data{ii}=transpose(data{ii});
end