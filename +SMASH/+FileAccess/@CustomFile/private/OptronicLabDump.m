function [data,header]=readOptronicLabDump(filename)

% open file and determine the number of lines
fid=fopen(filename,'r');
CU=onCleanup(@() fclose(fid));

N=0;
while ~feof(fid)
    fgetl(fid);
    N=N+1;
end
frewind(fid);

% read each line
header=cell(N,1);
data=cell(N,1);
kHeader=0;
kData=0;
points=0;
for k=1:N
    temp=fgetl(fid);
    if isempty(strtrim(temp))
        continue
    end
    [new,~,~,next]=sscanf(temp,'%g');
    if isempty(temp(next:end))
        kData=kData+1;        
        data{kData}=reshape(new,1,[]);
        points=points+1;
    else
        if points > 0
            kHeader=kHeader+1;
            header{kHeader}=sprintf('   (%d data points read)',points);
            points=0;
        end
        kHeader=kHeader+1;
        header{kHeader}=temp;
    end    
end
data=data(1:kData);
header=header(1:kHeader);

try
    data=cell2mat(data);
catch
    warning('Inconsistent number of columns--data returned as cell array');
end

end