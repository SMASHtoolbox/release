function [data,config,back]=read_sydor(filename)

if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.hdf;*.HDF','Select Sydor HDF file');
    filename=[pname fname];
end

% read configuration
info=hdfinfo(filename);

config=struct('File',[]);
try
    N=numel(info.Attributes);
    for n=1:N
        name=info.Attributes(n).Name;
        value=info.Attributes(n).Value;
        config.File.(name)=value;
    end
catch
end

M=numel(info.SDS);
for m=1:M    
    record=info.SDS(m).Name;    
    N=numel(info.SDS(m).Attributes);
    for n=1:N
        name=info.SDS(m).Attributes(n).Name;
        value=info.SDS(m).Attributes(n).Value;
        config.(record).(name)=value;
    end
end

% read data
fore=double(hdfread(filename,'fore'));
try
    back=double(hdfread(filename,'back'));
    data=fore-back;
catch
   data=fore;
   back=[];
end

end