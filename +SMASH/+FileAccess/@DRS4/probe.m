% probe Probe data file
%
% This *static* method probes the content of a DRS4 file.
%    report=DRS4.probe(object);
% The output "report" is a structure array, with one element per
% acquisition event.  Omitting the output:
%    DRS4.probe(object);
% prints file information in the command window.
%
% See also DRS4, read
%
function varargout=probe(varargin)

try
    [file,format]=packtools.call('DRS4.select',varargin{:});
catch ME
    throwAsCaller(ME);
end

try
    fid=fopen(file,'r','ieee-le');
catch ME
    throwAsCaller(ME);
end
CU=onCleanup(@() fclose(fid));

switch format
    case 'text'
        report=probeText(fid);
    case 'binary'
        report=probeBinary(fid);
end

% manage output
if nargout == 0
    fprintf('DRS file "%s"\n',file);
    for n=1:numel(report)
        SN=sprintf('SN%s',report(n).Board);
        channels=SMASH.Text.sprintPlural(report(n).Channels,'channel');
        fprintf('   Event %d (%s, %s)\n',n,SN,channels);
    end
else
    varargout{1}=report;
    varargout{2}=file;
    varargout{3}=format;
end  

end

%%
function report=probeText(fid)

source=fscanf(fid,'%c',[1 inf]);
source=extractBetween(source,'<DRSOSC>','</DRSOSC>');
assert(~isempty(source),'ERROR: file contains no DRS4 data');
raw=extractBetween(source,'<Event>','</Event>');
report=struct('Channels',[],'Board','','Time','','Points',0);
Nevent=numel(raw);
report=repmat(report,[1 Nevent]);
for n=1:Nevent
    temp=extractBetween(raw{n},'<CHN','>');
    temp=sprintf('%s ',temp{:});
    report(n).Channels=transpose(sscanf(temp,'%d'));
    temp=strfind(raw{n},'<Data>');
    report(n).Points=numel(temp)/numel(report(n).Channels);
    temp=extractBetween(raw{n},'<Board_','>');
    report(n).Board=temp{1};
    temp=extractBetween(raw{n},'<Time>','</Time>');
    report(n).Time=temp{1};
end

end

%%
function [report,version]=probeBinary(fid)
ERRMSG='ERROR: invalid DRS4 binary file';

buffer=transpose((fread(fid,4,'*char')));
assert(strcmp(buffer(1:3),'DRS'),ERRMSG);
version=buffer(end);

buffer=transpose(fread(fid,4,'*char'));
assert(strcmp(buffer,'TIME'),ERRMSG);

points=[];
board=[];
while ~feof(fid) % parse time header(s)
    buffer=transpose(fread(fid,4,'*char'));
    if strcmp(buffer,'EHDR')
        fseek(fid,-4,'cof');
        break
    elseif strcmp(buffer(1:2),'B#')
        fseek(fid,-2,'cof');
        SN=fread(fid,1,'*uint16');
        if isempty(board)
            board=struct('Number',SN,'Channels',[],'Points',0);
        else           
            board(end+1).Number=SN; %#ok<AGROW>
        end 
        continue
    end
    channel=sscanf(buffer,'C%d',1);
    temp=sprintf('C%03d',channel);
    if strcmp(temp,buffer)
        board(end).Channels(end+1)=channel;
        points(end+1)=0; %#ok<AGROW>
    else
        points(end)=points(end)+1;
    end    
end

for n=1:numel(points)
    board(n).Points=points(n); %#ok<AGROW>
end

while ~feof(fid) % parse event header(s)
    buffer=transpose(fread(fid,4,'*char'));
    if ~strcmp(buffer,'EHDR')
        continue
    end
    event=fread(fid,1,'*uint32');
    if event == 1
        report=struct('Board',[],'Channels',[],'Time','','Points',0);
    else
        report(end+1)=report(end); %#ok<AGROW>
    end
    temp=fread(fid,7,'*uint16');
    report(end).Time=sprintf('%d/%d/%d %d:%d:%d.%d',temp);
    fseek(fid,+4,'cof');
    number=fread(fid,1,'*uint16');
    for k=1:numel(board)
        if board(k).Number == number
            report(end).Board=sprintf('%d',number);
            report(end).Channels=board(k).Channels;
            report(end).Points=board(k).Points;
            break
        end
    end
    
end

end