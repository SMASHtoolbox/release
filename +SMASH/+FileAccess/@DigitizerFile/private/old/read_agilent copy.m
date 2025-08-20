function [signal,time]=read_agilent(filename,index)

% handle input
if (nargin<1) || isempty(filename)
    types={};
    types(end+1,:)={'*.h5;*.H5','Agilent HDF5 files'};
    types(end+1,:)={'*.*','All files'};
    [filename,pathname]=uigetfile(types,'Select Agilent data file');
    if isnumeric(filename) % user pressed cancel
        return
    end
    filename=fullfile(pathname,filename);
end

if (nargin<2) || isempty(index)
    index=1;
end

% extract data
info=hdf5info(filename);
info=info.GroupHierarchy.Groups(3);
%num_signal=info.Attributes.Value;

[signal,time,label]=deal(cell(numel(index),1));
for n=1:numel(index)
    group=info.Groups(index(n));
    label{n}=group.Name;
    name=group.Datasets.Name;
    if exist('h5read','file')
        signal{n}=h5read(filename,name);
    elseif exist('hdf5read','file')
        signal{n}=hdf5read(filename,name);
    else
        error('ERROR: unable to read HDF5 files in this version of MATLAB');
    end
    signal{n}=double(signal{n}(:));
    YInc=group.Attributes(13).Value;
    YOrg=group.Attributes(15).Value;
    signal{n}=YOrg+YInc*signal{n};
    numpoints=numel(signal{n});
    dx=group.Attributes(8).Value;
    left=group.Attributes(9).Value;    
    right=left+(numpoints-1)*dx;
    time{n}=left:dx:right;
    time{n}=double(time{n}(:));
end

if numel(signal)==1
    signal=signal{1};
    time=time{1};
    label=label{1};
end

end