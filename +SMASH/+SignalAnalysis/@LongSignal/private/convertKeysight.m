% H5 only (for now)
function convertKeysight(file,record,target,option)

% scan *.h5 file
location='/Waveforms';
try
    info=h5info(file,location);
catch
    error('ERROR: invalid digitizer file');
end
info=info.Groups;

keep=false(size(info));
for k=1:numel(info)
    [~,name]=fileparts(info(k).Name);
    index=sscanf(name,'Channel %d',1);
    if isempty(index)
        continue
    elseif isempty(record) || (index == record)
        keep(k)=true;        
    end
end
info=info(keep);

data=struct('Location','','Points',[],...
    'Start',[],'Increment',[],'Y0',[],'DY',[]);
data=repmat(data,size(info));
for k=1:numel(info)   
    data(k).Location=[info(k).Name '/' info(k).Datasets(1).Name];
    data(k).Points=double(h5readatt(file,info(k).Name,'NumPoints'));
    data(k).Start=h5readatt(file,info(k).Name,'XOrg');
    data(k).Increment=h5readatt(file,info(k).Name,'XInc');
    data(k).Y0=h5readatt(file,info(k).Name,'YOrg');
    data(k).DY=h5readatt(file,info(k).Name,'YInc');
end

% perform conversion
columns=numel(data);
%rows=min(data(1).Points,option.Chunk);

h5create(target,'/Signal',[inf inf],...
    'ChunkSize',[option.Chunk columns],'Deflate',option.Deflate);
h5writeatt(target,'/Signal','GridStart',data(1).Start);
h5writeatt(target,'/Signal','GridStop',...
    data(1).Start+(data(1).Points-1)*data(1).Increment);
h5writeatt(target,'/Signal','GridIncrement',data(1).Increment);

fprintf('Conversion status: ');
start=1;
while start <= data(1).Points
    count=fprintf('%.1f%%',start/data(1).Points*100);
    stop=min(start+option.Chunk-1,data(1).Points);
    L=stop-start+1;
    block=nan(L,columns);        
    for k=1:columns
        temp=h5read(file,data(k).Location,start,L);
        temp=double(temp);
        block(:,k)=data(k).Y0+data(k).DY*temp(:);
    end
    h5write(target,'/Signal',block,[start 1],[L columns]);    
    start=stop+1;    
    backspace=repmat('\b',[1 count]);
    fprintf(backspace);
end
fprintf('complete\n');

end