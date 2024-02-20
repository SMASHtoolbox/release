% tdscvsread   :   Reads *.CVS files from TDS scopes
% [x,y]=wfmread(filename)
% filenmame is a character string name of a *.CVS file.
% Created 7/29/200r by Dan Dolan
%
function [x,y]=tdscsvread(filename)

if nargin<1
    filename='';
end
if isempty(filename)
    [fname,pname]=uigetfile('*.csv;*.CSV','Choose Tektronix CSV file');
    filename=[pname fname];
end

fid=fopen(filename,'r');
if fid<0
    error(['Unable to open file' filename]);
end

% find the data below header
temp=fgets(fid);
while any(strfind(temp,'"'))
    temp=fgets(fid);
end

data=fscanf(fid,'%s'); % remove extra white space
fclose(fid);

format='%*3c%g%*c%g';
temp=sscanf(temp,format);
data=sscanf(data,format,[2 inf]);

x=[temp(1) data(1,:)];
y=[temp(2) data(2,:)];