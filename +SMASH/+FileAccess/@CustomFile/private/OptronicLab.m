% Read data from Optronic Laboratory 750 Spectradiometer file
% [lambda,measurement,fileinfo]=OptronicLab(filename)

% Created 3/1/2004 by Daniel Dolan
%
function [lambda,measurement,fileinfo]=OptronicLab(filename)

if nargin<1
    filename=[];
end
if isempty(filename)
   [fname,pname]=uigetfile({...
           '*.dat;*.DAT','Data files (*.dat,*.DAT)';...
           '*.cal;*.CAL','Calibration files (*.cal,*.CAL)';...
       },'Choose Optronics file');
   filename=[pname fname];
end
if ~exist(filename)
    error('File does not exist');
end

fid=fopen(filename,'r');

% read header line
temp=fgets(fid);
commas=findstr(temp,',');
jj=1;
for ii=1:length(commas) % extract header fields
    kk=commas(ii)-1;
    header{ii}=temp(jj:kk);
    jj=commas(ii)+1;
end
header{ii+1}=temp(jj:end);

% place header info in structure
fileinfo.title=header{1};
fileinfo.units=header{2};
fileinfo.date=header{3};
wlmin=str2num(header{4});
fileinfo.wlmin=wlmin;
wlmax=str2num(header{5});
fileinfo.wlmax=wlmax;
wlinc=str2num(header{6});
fileinfo.wlinc=wlinc;

lambda=wlmin:wlinc:wlmax;
measurement=fscanf(fid,'%g',[1 length(lambda)]);
N=length(measurement);
if length(lambda)~=N
    lambda=lambda(1:N);
end
fclose(fid);