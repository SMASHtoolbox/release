% OceanOptics : read Ocean Optics spectrometer data
%
% Usage: 
% >> [wavelength,counts,rate,header]=OceanOptics(filename);
%

% created 11/12/2010 by Daniel Dolan (Sandia National Laboratories)
function [wavelength,counts,rate,header]=OceanOptics(filename)

% handle input
if (nargin<1) || isempty(filename)
    [filename,pathname]=uigetfile('*.*','Select Ocean Optics file');
    if isnumeric(filename)
        return
    end
    filename=fullfile(pathname,filename);
end

% scan data file
%[data,header]=ColumnReader(filename);
object=SMASH.FileAccess.ColumnFile(filename);
temp=read(object);
data=temp.Data;
wavelength=data(:,1);
counts=data(:,2);
header=temp.Header;

% process header to get exposure time
exposure=1;
for n=1:numel(header)
    if strfind(header{n},'Integration Time')
        start=strfind(header{n},':')+1;
        exposure=sscanf(header{n}(start:end),'%g',1);        
        exposure=exposure/1e6; % convert microseconds to seconds
    end
end
rate=counts/exposure;

end