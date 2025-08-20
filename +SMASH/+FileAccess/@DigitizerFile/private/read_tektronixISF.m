function varargout=read_tektronixISF(filename)

if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.isf;*.ISF','Choose Tektronix ISF file');
    if isnumeric(fname)
        return
    end
    filename=[pname fname];
end

% open file
fid=fopen(filename,'r');

% skip :WFMPRE: or :WFMP: entry
fscanf(fid,'%1c',1);
entry='';
while true
    temp=fscanf(fid,'%1c',1);
    if strcmp(temp,':')
        break
    end
    entry(end+1)=temp;
end

% read ASCII header
header='';
while true
    temp=fscanf(fid,'%1c',1);
    if strcmp(temp,'#')
        break
    end
    header(end+1)=temp;
end
% Trim down header
doubleColons = strfind(header, ':WFMPRE:'); % quick fix on 4/14/2023
if numel(doubleColons) < 3
    colons=findstr(header,':');
    if numel(colons) < 2
        header=header(1:colons-1);
    else
        header=header(colons(end-1)+1:colons(end)-1);
    end
else
    header = erase(header, ':WFMPRE:');
    header = erase(header, ':CURVE');
end

% skip the CURVE entry
temp=fscanf(fid,'%1c',1);
temp=sscanf(temp,'%d');
format=sprintf('%%%dc',temp);
fscanf(fid,format,1);

% process header
temp=header;
header=struct;
while numel(temp)>0
    [local,temp]=strtok(temp,';');
    [name,value]=strtok(local);
    value=strtrim(value);
    new=sscanf(value,'%g',1);
    if value(1)=='"' % remove extra quotes
        value=value(2:end-1);
    elseif ~isempty(new)
        value=new;
    end
    header.(name)=value;
    temp=strtrim(temp(2:end));
end

% read data
if strcmp(entry,'WFMP')
    BIT=header.BIT_N;
    BYT=header.BYT_O;
    numpoints=header.NR_P;
    x0=header.XZE;
    dx=header.XIN;
    pt=header.PT_OFF;
    y0=header.YOF;
    scale=header.YMU;
    yz=header.YZE;
else
    BIT=header.BIT_NR;
    BYT=header.BYT_OR;
    numpoints=header.NR_PT; 
    x0=header.XZERO;
    dx=header.XINCR;
    pt=header.PT_OFF;
    y0=header.YOFF;
    scale=header.YMULT;
    yz=header.YZERO;
end

switch BIT
    case 8
        precision='int8';
    case 16
        precision='int16';
    otherwise
        error('ERROR: unrecognized number of bits specified');
end
 
switch BYT
    case 'LSB'
        machineformat='ieee-le';
    case 'MSB'
        machineformat='ieee-be';
    otherwise
        error('ERROR: unrecognized bit order specified');
end

skip=0;
data.y=fread(fid,numpoints,precision,skip,machineformat);
fclose(fid);

% define time axis
x1=x0+(1-pt)*dx;
x2=x0+(numpoints-pt)*dx;
data.x=x1:dx:x2;

% scale vertical axis
data.y=scale*(data.y-y0)+yz;

% handle output
if nargout==0
    figure;
    plot(data.x,data.y);
end

if nargout>=1
    varargout{1}=data.y;
end

if nargout>=2
    varargout{2}=data.x;
end
