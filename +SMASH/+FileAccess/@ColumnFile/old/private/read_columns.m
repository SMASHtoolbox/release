function [data,header]=read_columns(filename,varargin)

% input check
[numcol,skip,format]=probe_columns(filename,varargin{:});
fid=fopen(filename,'r');     
finish=onCleanup(@() fclose(fid));

% read header and column data
fid=fopen(filename,'r');     
finish=onCleanup(@() fclose(fid));

header=cell(skip,1);
for ii=1:skip
    header{ii}=fgetl(fid);
end

[data,count]=fscanf(fid,format,[numcol inf]);
if rem(count,numcol)~=0 % partial read
    data=data(:,1:end-1);
end
data=transpose(data);