% read Read data file
%
% This *static* method reads data from a DRS4 file.
%    data=DRS4.read(object);
% The output "data" is structure array, with one element per acquisition
% event.
%
% See also DRS4, plot, probe
%
function data=read(varargin)

try
    [report,file,format]=packtools.call('DRS4.probe',varargin{:});
catch ME
    throwAsCaller(ME);
end
fid=fopen(file,'r','ieee-le');
CU=onCleanup(@() fclose(fid));

switch format
    case 'text'
        source=fscanf(fid,'%c',[1 inf]);
        source=extractBetween(source,'<DRSOSC>','</DRSOSC>');
        data=readText(source{1});
    case 'binary'
        data=readBinary(fid,report);
    otherwise
        error('ERROR: invalid file format');
end

end

function data=readText(source)

new=struct('Board','','Time','','HUnit','','VUnit','',...
    'Channel1',[],'Channel2',[],'Channel3',[],'Channel4',[]);
content=extractBetween(source,'<Event>','</Event>');
N=numel(content);
list={'Time' 'HUnit' 'VUnit' 'CHN1' 'CHN2' 'CHN3' 'CHN4'};
for n=1:N 
    temp=extractBetween(content{n},'<Board_','>');    
    new.Board=temp{1};        
    for k=1:numel(list)
        start=sprintf('<%s>',list{k});
        stop=sprintf('</%s>',list{k});
        temp=extractBetween(content{n},start,stop);
        if isempty(temp)
            continue
        elseif startsWith(list{k},'CHN')
            label=strrep(list{k},'CHN','Channel');
            temp=sscanf(temp{1},'%*6s%g,%g%*7s',[2 inf]);
            new.(label)=transpose(temp);
        else
            new.(list{k})=temp{1};
        end
    end            
    if n == 1
        data=repmat(new,[1 N]);
    else
        data(n)=new;
    end
end


end

%%
function data=readBinary(fid,report)

points=1024; % 2048 models decimate to 1024 points in binary files
width=nan(points,4);

fseek(fid,12,'bof');
while ~feof(fid)
    buffer=transpose(fread(fid,4,'*char'));
    if strcmp(buffer,'EHDR')
        fseek(fid,-4,'cof');
        break
    end
    channel=sscanf(buffer,'C%d');
    width(:,channel)=fread(fid,points,'*single');
end

Nevent=numel(report);
data=struct('Board',report.Board,'HUnit','ns','VUnit','mV',...
    'Channel1',[],'Channel2',[],'Channel3',[],'Channel4',[]);
data=repmat(data,[1 Nevent]);
for n=1:Nevent
    buffer=transpose(fread(fid,4,'*char'));
    assert(strcmp(buffer,'EHDR'),'ERROR: invalid event');
    fseek(fid,4,'cof'); % skip serial number
    fseek(fid,14,'cof'); % skip date/time info
    RC=fread(fid,1,'int16'); % range center (mV)
    fseek(fid,4,'cof'); % skip board number
    fseek(fid,2,'cof'); % skip T#
    Tcell=fread(fid,1,'uint16'); % trigger cell
    for channel=report(n).Channels
        buffer=transpose(fread(fid,4,'*char'));
        assert(strcmp(buffer,sprintf('C%03d',channel)),...
            'ERROR: invalid channel header');
        scaler=fread(fid,1,'single'); %#ok<NASGU>
        voltage=fread(fid,points,'uint16');
        voltage=1000*voltage/65535+RC-500; % mV
        index=[Tcell:1024 1:Tcell-1];
        time=cumsum(width(index,channel));
        time=time-time(1);
        voltage=voltage(index);
        label=sprintf('Channel%d',channel);
        data(n).(label)=[time(:) voltage(:)];
    end    
end

end