% READ Read from a ColumnFile object
%
%    >> output=read(object,[delim],[mincol]);
% The output is a structure with the following fields.
%    -FileName
%    -FileType
%    -Header
%    -Data
%
% see also ColumnFile, probe
%

function output=read(object,delim,mincol)

% handle input
if nargin<2
    delim=[];
end

if nargin<3
    mincol=[];
end

% initial preparations
report=probe(object,delim,mincol);
output.FileName=object.FileName;
output.Format='column';

% scan file
fid=fopen(object.FullName,'r');     
finish=onCleanup(@() fclose(fid));

N=report.HeaderLines;
output.Header=cell(N,1);
for n=1:N
    output.Header{n}=fgetl(fid);
end

N=report.NumberColumns;
[data,count]=fscanf(fid,report.Format,[N inf]);
if rem(count,N)~=0 % partial read
    data=data(:,1:end-1);
end
output.Data=transpose(data);

end