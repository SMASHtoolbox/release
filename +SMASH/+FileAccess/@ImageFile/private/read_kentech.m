function [data,info]=read_kentech(filename)

if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.hdf;*.HDF','Select Kentech HDF file');
    filename=[pname fname];
end

% read configuration
info=hdfinfo(filename);
N=numel(info.SDS);

for n=N:-1:1    
    temp=hdfread(filename,info.SDS(n).Name);
    data(n).Grid1=1:size(temp,2);
    data(n).Grid2=1:size(temp,1);
    data(n).Data=double(temp);     
end

end