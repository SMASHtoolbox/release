% READ Read from a column block file
%
%    >> output=read(object,[delim],[mincol]);
% The output is a structure with the following fields.
%    -FileName
%    -FileType
%    -Header
%    -Data
%
% see also BlockFile, probe
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
output.Format='block';

% scan file
fid=fopen(object.FullName,'r');     
finish=onCleanup(@() fclose(fid));

N=numel(report);
output.Data=cell(N,1);
output.Header=cell(N,1);
for block=1:N
    fseek(fid,report(block).Start,'bof');
    M=report(block).HeaderLines;
    output.Header{block}=cell(M,1);
    for m=1:M
        output.Header{block}{m}=fgetl(fid);        
    end
    data=fscanf(fid,report(block).Format,[report(block).NumberColumns inf]);
    output.Data{block}=transpose(data);
end

end