function [time,signal,header]=read_OBR(filename)

% prepare file handle
fid=fopen(filename,'r','ieee-le');
finishup = onCleanup(@() fclose(fid));

% header
header.FormatVersion=fread(fid,1,'float32');
header.Descriptor=fread(fid,8,'*char');
header.Descriptor=header.Descriptor;

header.StartFrequency=fread(fid,1,'float64');
header.FrequencyIncrement=fread(fid,1,'float64');
header.StartTime=fread(fid,1,'float64');
header.TimeIncrement=fread(fid,1,'float64');

header.MeasurementType=fread(fid,1,'uint16');
header.GroupIndex=fread(fid,1,'float64');
header.GainValue=fread(fid,1,'int32');

header.ZeroLengthIndex=fread(fid,1,'int32');
header.DataTypeSize=fread(fid,1,'uint32');
header.NumberPoints=fread(fid,1,'uint32');

header.MeasurementTime=fread(fid,8,'uint16');
header.CalibrationTime=fread(fid,8,'uint16');
 
header.TemperatureCoefficients=fread(fid,5,'float64');
header.StrainCoefficients=fread(fid,5,'float64');
header.FrequencyWindowFlag=fread(fid,1,'uint8');

c0=299792458; % [m/s]
header.GainAdjust=sqrt(2*header.GroupIndex*1e6/(c0*header.TimeIncrement));

name=fields(header);
for k=1:numel(name)
    value=header.(name{k});
    value=reshape(value,[1 numel(value)]);
    header.(name{k})=value;    
end

% data
fseek(fid,2048,'bof');
N=header.NumberPoints/2;

Preal=fread(fid,N,'float64');
Pimag=fread(fid,N,'float64');
Sreal=fread(fid,N,'float64');
Simag=fread(fid,N,'float64');

signal=Preal.^2+Pimag.^2+Sreal.^2+Simag.^2;
signal=signal*(header.GainAdjust)^2;

N=numel(signal);
time=header.StartTime+(0:N-1)*header.TimeIncrement;

end