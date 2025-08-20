function [time,signal,header]=read_text(filename)

% read data file into structure
data=SMASH.FileAccess.readFile(filename,'column');

% process header
header=struct();
header.Contents=data.Header;

for n=1:numel(data.Header)
    temp=data.Header{n};
    if any(regexpi(temp,'group index'))
        while numel(temp)>0
            n=sscanf(temp,'%g',1);            
            if isempty(n)
                temp=temp(2:end);
            else
                break
            end
        end
        header.GroupIndex=n;
    end    
end

temp=double(data.Header{end});
stop=find(temp==9); % tab character
N=numel(stop);
start=1;
TimeColumn=nan;
DataColumn=nan;
for k=1:N
    temp=data.Header{end}(start:stop(k));
    if regexpi(temp,'Time')
        TimeColumn=k;
    elseif regexpi(temp,'Linear Amplitude')
        DataColumn=k;
    end
    start=stop(k)+1;        
end
assert(~isnan(TimeColumn),'ERROR: Time column not found');
time=data.Data(:,TimeColumn);
assert(~isnan(DataColumn),'ERROR: Linear Amplitude column not fond');
signal=data.Data(:,DataColumn);

end