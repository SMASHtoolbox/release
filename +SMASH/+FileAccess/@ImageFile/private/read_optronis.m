
% revised May 28, 2014 by Daniel Dolan
%   -Automatically remove periods from field names
%
function [data,config,header]=read_optronis(filename)

if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.imd;*.IMD','Select Optronis IMD file');
    filename=[pname fname];
end

% open and read IMD file
fid=fopen(filename,'rb');

version=fread(fid,1,'uint16');
width=fread(fid,1,'uint16');
height=fread(fid,1,'uint16');
header=struct('version',version,'width',width,'height',height);

data=fread(fid,width*height,'int32');
fclose(fid);

% transform data to usable form
data=reshape(data,[width height]);
data=transpose(data);
data=data/1000; % convert int32 number to floating point value

% try to read IMI file corresponding to the IMD file
config=struct();
[pname,fname,~]=fileparts(filename);
target=fullfile(pname,[fname '.imi']);
fid=fopen(target,'rt');
if fid<0
    fprintf('No IMI file found\n');
    return
end

while ~feof(fid)
    % read a line and see it defines a new group
    temp=fgetl(fid);
    if strcmp(temp(1),'[') && strcmp(temp(end),']')
        group=sscanf(temp(2:end-1),'%s');
        continue
    end
    % separate field name and value
    separator=find(temp=='=',1,'first');
    if numel(separator)<1
        fprintf('Separator missing in IMI file:\n')
        fprintf('\t%s\n',temp);
        continue
    end
    name=sscanf(temp(1:separator-1),'%s');
    drop=(name=='.');
    name=name(~drop);    
    % process the field value
    value=temp(separator+1:end);
    [junk,count,~,next]=sscanf(value,'%g');
    if (count==1) && isempty(value(next:end))
        value=junk;    
    end
    % store the current field in the current group
    config.(group).(name)=value;
end
fclose(fid);