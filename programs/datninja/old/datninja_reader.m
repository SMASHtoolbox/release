% datninja_reader : read data file created by datninja
% Usage:
% >> [x,y]=datninja_reader(filename);
%

% created November 24, 2008 by Daniel Dolan (Sandia National Labs)
function [x,y]=datninja_reader(filename)

message{1}='The datninja program is obsolete and will be removed in future toolbox releases';
message{2}='Use the datninja app instead';
warning('%s\n',message{:});

% prompt user if file name is missing
if (nargin<1) || isempty(filename)
    filterspec={};
    filterspec(1,:)={'*.txt;*.TXT'; 'Text files'};
    filterspec(2,:)={'*.*' 'All files'};
    [filename,pathname]=uigetfile(filterspec,'Select data file');
    if isnumeric(filename) 
        return 
    end
    filename=fullfile(pathname,filename);    
end

% read data points from file
[x,y]=deal([]);
fid=fopen(filename,'rt');
while ~feof(fid)
    temp=fgetl(fid);
    [first,count,err,next]=sscanf(temp,'%s',1);    
    if strcmp(first,'data:')
        temp=temp(next:end);
        [value,count]=sscanf(temp,'%g');
    else 
        continue
    end
    if  count>=4
        x(end+1)=value(3);
        y(end+1)=value(4);
    else
        continue
    end        
end