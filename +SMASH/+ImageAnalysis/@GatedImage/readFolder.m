% UNDER CONTRUCTION
% readFolder Read image folder
%


function data=readFolder(location)

data=struct();

if nargin < 0
    location=uigetdir(pwd,'Select image folder');
    if isnumeric(location)       
        return
    end
else
    assert(ischar(location) && isfolder(location),...
        'ERROR: invalid image folder');    
end

% Cordin framing camera
file=fullfile(location,'capture.xml');
subfolder=fullfile(location,'RAW');
if isfile(file) && isfolder(subfolder)
    data=readCordinRAW(subfolder,file);
    return
end

file=fullfile(location,'parameters.txt');
subfolder=fullfile(location,'TIFF16');
if isfile(file) && isfolder(subfolder)
    data=readCordinTIFF(subfolder,file);
    return
end

% generic image directory
data.Info=struct();
data.Frame=[];
file=dir(location);
for n=1:numel(file)
    try
        raw=imread(fullfile(file(n).folder,file(n).name));
    catch
        continue
    end
    new=struct('FileName',file(n).name,'Data',double(raw));
    if isempty(data.Frame)
        data.Frame=new;
    else
        data.Frame(end+1)=new;
    end
end


end

%%
function data=readCordinRAW(location,file)

fid=fopen(file,'r');
buffer=fscanf(fid,'%c',[1 inf]);
fclose(fid);
    function [header,body]=extractBlock(source,name)       
        start=sprintf('<%s',name);
        stop=sprintf('</%s>',name);       
        block=extractBetween(source,start,stop);
        if isempty(block)
            stop='/>';
            block=extractBetween(source,start,stop);
        end
        MM=numel(block);
        [header,body]=deal(cell(1,MM));
        for mm=1:MM
            index=find(block{mm} == '>',1,'first');
            if ~isempty(index)
                body{mm}=block{mm}(index+1:end);
                local=block{mm}(1:index-1);
            else
                body{mm}='';
                local=block{mm};
            end
            name=extractBetween(local,' ','="');
            value=extractBetween(local,'="','"');
            header{mm}=struct();
            for nn=1:numel(name)
                if contains(value{nn},'http://') || ~isvarname(name{nn})
                    continue
                end
                [temp,~,~,next]=sscanf(value{nn},'%g',1);
                if isempty(value{nn}(next:end))
                    header{mm}.(name{nn})=temp;
                else
                    header{mm}.(name{nn})=value{nn};
                end                
            end
        end                        
    end

[header,body]=extractBlock(buffer,'CaptureInfo');
general=header{1};
body=body{1};    

header=extractBlock(body,'CameraDetails');
general.Details=header{1};

header=extractBlock(body,'TechnicalNotes');
general.Notes=header{1};

[~,temp]=extractBlock(body,'Timescale');
general.Timescale=temp{1};

[frame,body]=extractBlock(body,'FrameInfo');
M=numel(frame);
for m=1:M
    info=general;
    name=fieldnames(frame{m});    
    for n=1:numel(name)
        info.(name{n})=frame{m}.(name{n});
    end    
    [~,temp]=extractBlock(body{m},'FileName');
    file=temp{1};
    frame{m}.FileName=file;           
    fid=fopen(fullfile(location,file),'r');    
    raw=fread(fid,[1 inf],'uint16',0,'b');
    fclose(fid);
    temp=extractBetween(file,'_','.raw');
    L=sscanf(temp{1},'%dx%d');
    raw=reshape(raw(end:-1:1),transpose(L));
    raw=transpose(raw);
    new=struct('Info',info,'RawData',raw);
    if m == 1
        data=repmat(new,[M 1]);
    else
        data(m)=new;
    end
end

end

function data=readCordinTIFF(location,file)

fid=fopen(file,'r');
while ~feof(fid)
    buffer=fgetl(fid);
    index=find(buffer == ':',1,'first');
    if isempty(index)
        continue
    end
    name=matlab.lang.makeValidName(buffer(1:index-1));
    value=strtrim(buffer(index+1:end));
    general.(name)=value;
end
fclose(fid);

file=dir(fullfile(location,'*.tiff'));
M=numel(file);
for m=1:M
    info=general;
    info.FileName=file(m).name;
    raw=imread(fullfile(file(m).folder,file(m).name));
    new=struct('Info',info,'RawData',double(raw));
    if m == 1        
        data=repmat(new,[M 1]);
    else
        data(m)=new;
    end
end

end