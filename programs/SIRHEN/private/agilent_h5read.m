function [signal,time]=read_agilent(filename,index)

% manage input
if (nargin<1) || isempty(filename)
    types={};
    types(end+1,:)={'*.h5;*.H5','Agilent/Keysight HDF5 files'};
    types(end+1,:)={'*.*','All files'};
    [filename,pathname]=uigetfile(types,'Select Agilent/Keysight data file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    filename=fullfile(pathname,filename);
end

if (nargin<2) || isempty(index)
    index=1;
end

% extract data
report=probe_agilent(filename);
[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.h5'
        [time,signal]=read_agilentH5(filename,index,report);
    case '.bin'
        [time,signal]=read_agilentBIN(filename,index,report);
end

if numel(signal)==1
    signal=signal{1};
    time=time{1};
end

end

%%
function [time,signal]=read_agilentH5(filename,index,report)

try
    report.Name=report.Name(index);
    report.GroupName=report.GroupName(index);
    report.DatasetName=report.DatasetName(index);
    report.NumberSignals=numel(index);
catch
    error('ERROR: invalid signal index');
end

[signal,time]=deal(cell(numel(index),1));
for n=1:numel(index)
    % read attributes
    info=h5info(filename,report.GroupName{n});
    N=numel(info.Attributes);
    [name,value]=deal(cell(1,N));
    for k=1:N
        temp=info.Attributes(k);
        name{k}=temp.Name;
        value{k}=temp.Value;
    end
    attribute=cell2struct(value,name,2);
    % read/convert data
    signal{n}=h5read(filename,report.DatasetName{n});
    if isinteger(signal{n})
        signal{n}=double(signal{n});
        y0=double(attribute.YOrg);
        dy=double(attribute.YInc);
        signal{n}=y0+dy*signal{n};
    else
        signal{n}=double(signal{n}(:));
    end
    numpoints=double(attribute.NumPoints);
    dx=double(attribute.XInc);
    left=double(attribute.XOrg);
    right=left+(numpoints-1)*dx;
    time{n}=left:dx:right;
    time{n}=double(time{n}(:));
end

end

%%
function [time,signal]=read_agilentBIN(filename,index,report)

index=report.IndexTable(index,2:3);

try
    info=report.Waveform(index(1)).Dataset(index(2));
catch
    error('ERROR: invalid index');
end;

Npoints=report.Waveform(index(1)).Points;
switch info.BufferType
    case 0
        % unknown data
    case {1 2 3}
        format='single';
    case {4 5}
        % not used?
    case 6
        format='uint8';
    otherwise
        error('ERROR: unrecogized buffer type')
end

fid=fopen(filename,'r','ieee-le');
fseek(fid,info.Start,'bof');
signal=fread(fid,Npoints,format);
fclose(fid);

tmin=report.Waveform(index(1)).XOrigin;
dt=report.Waveform(index(1)).XIncrement;
tmax=tmin+dt*(Npoints-1);
time=tmin:dt:tmax;

end