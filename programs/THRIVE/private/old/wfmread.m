% wfmread : Read Tektronix binary data files
%
% This function is an updated version of wfmread.  The original version
% (written by Daniel Dolan) supported the TDS XXX family of digitizers
% (e.g., TDS 694).  Tektronix has since released various TDS XXXX models
% (e.g., TDS 5000), which use a different binary file format; these files
% can be read into MATLAB using wfm2read (written by Erik Benkler).  This
% program can read files created by both digitizer families.
%
% Usage:
%
% Retrive vertical (y) and horizontal (t) data:
%  >>[y,t]=wfmread(filename);
% If filename is omitted or empty, the user will be prompted for one with a
% dialog box.
%
% Retrieve (t,y) data along with record information (number points, etc.):
%  >>[y,t,info]=wfmread;
%
%

% created 2/18/2006 by Daniel Dolan
% updated 10/14/2008 by Daniel Dolan
%   -modified wfmXXXXread to handle WFM003 format (four density values
%   changed from uint32 to double precision)
%   -corrected a minor error in the time base calculation
function [y,t,info,iover,iunder]=wfmread(filename)

% input check
if nargin<1
    filename='';
end
if isempty(filename)
    [fname,pname]=uigetfile('*.wfm;*.WFM','Choose Tektronix WFM file');
    filename=[pname fname];
end
if exist(filename)~=2
    id='wfmread:FileNotFound';
    message='File error: \n \t %s \n \t does not exist!\n';
    error(id,message,filename);
end

% make sure file can be opened 
fid=fopen(filename,'rb');
if fid==-1
    id='wfmread:FileNotOpened';
    message='File error: \n \t %s \n \t cannot be opened!\n';
    error(id,message,filename);
end

% call reader function based on the first eight characters
startA=char(fread(fid,8,'uchar')');
frewind(fid)
startB=dec2hex(fread(fid,1,'uint16'),4);
fclose(fid);
if strfind(startA,'LLWFM')
    [y,t,info]=wfmXXXread(filename);
    if nargout>3
        warning('Over/under-ranging not supported for TDS XXX data');
        iover=repmat(false,size(y));
        iunder=repmat(false,size(x));
    end
elseif strcmp(startB,'0F0F') || strcmp(startB,'F0F0')
    [y,t,info,iover,iunder]=wfmXXXXread(filename);
else % this is not a Tektronix WFM file
    [y,t,info,iover,iunder]=deal([]);
end

end 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y,t,info]=wfmXXXread(filename,mode)
    
[fp,message]=fopen(filename,'rb','b'); % big-endian format
if fp==-1
    error(['Unable to open file: ' filename]);
end

% main header
a=fread(fp,1,'uchar');
if char(a)==':'
   start=fread(fp,7,'uchar');
else
   start=fread(fp,6,'uchar');
end
start=char([a start']);
count_bytes=str2num(char(fread(fp,1,'uchar'))'); % number of bytes in count
bytes=str2num(char(fread(fp,count_bytes,'uchar'))'); % bytes to end of file
magic_num=fread(fp,1,'int32'); % "magic number"
length=fread(fp,1,'int32'); % length of header+curve data

% reference header
vertPos=fread(fp,1,'double');
horzPos=fread(fp,1,'double');
vertZoom=fread(fp,1,'double');
horzZoom=fread(fp,1,'double');

% waveform header
acqmode=fread(fp,1,'int16');
minMaxFormat=fread(fp,1,'int16');
duration=fread(fp,1,'double');
vertCpl=fread(fp,1,'int16');
horzUnit=fread(fp,1,'int16');
horzScalePerPoint=fread(fp,1,'double');
vertUnit=fread(fp,1,'int16');
vertOffset=fread(fp,1,'double');
vertPos=fread(fp,1,'double');
vertGain=fread(fp,1,'double');
%recordLength=fread(fp,1,'uint64');
recordLength=fread(fp,1,'uint32');
trigPos=fread(fp,1,'int16');
wfmHeaderVersion=fread(fp,1,'int16');
sampleDensity=fread(fp,1,'int16');
burstSegmentLength=fread(fp,1,'int16');
sourceWfm=fread(fp,1,'int16');
video1=fread(fp,3,'int16');
video2=fread(fp,1,'double');
video3=fread(fp,1,'int16');

% check to see extended header is present
if (length-2*recordLength-2*32)==196
   % do something (eventually)
end

% store important info
info.nop=recordLength;
switch horzUnit
    case 609
        info.tunit='volts';
    case 610
        info.tunit='seconds';
        info.samplingrate=horzScalePerPoint;
        info.duration=duration;
end
switch vertUnit
    case 609
        info.yunit='volts';
    case 610
        info.yunit='seconds';
end
switch vertCpl
    case 565
        unit.ycoupling='DC';
    case 566
        unit.ycoupling='AC';
end

% extract the data
preamble=fread(fp,16,'int16');
data=fread(fp,recordLength,'int16');
postamble=fread(fp,16,'int16');
checksum=fread(fp,1,'int16');
fclose(fp);

% calculate thet and y data series
ii=0:(recordLength-1);
t=(ii'-recordLength*trigPos/100)*horzScalePerPoint;
y=data*vertGain/25/256+vertOffset-vertPos*vertGain;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [y, t, info, ind_over, ind_under] = wfmXXXXread(filename, datapoints)
   
if nargin<2
    datapoints=[];
end

[fid,message]=fopen(filename);

%read the waveform static file info 
byte_order_verification = dec2hex(fread(fid,1,'uint16'),4);
if byte_order_verification == '0F0F'
    byteorder='l'; % little-endian byte order
else 
    byteorder='b'; % big-endian byte order
end
versioning_number = char(fread(fid,8,'*char',byteorder)');
if strcmp(versioning_number,':WFM#003')
    version3=true;
else
    version3=false;
end

num_digits_in_byte_count = fread(fid,1,'*uint8',byteorder);
num_bytes_to_EOF = fread(fid,1,'*int32',byteorder);
num_bytes_per_point = fread(fid,1,'uint8',byteorder); %do not convert to same type, since required as double later
byte_offset_to_beginning_of_curve_buffer = fread(fid,1,'*uint32',byteorder);
horizontal_zoom_scale_factor = fread(fid,1,'*int32',byteorder);
horizontal_zoom_position = fread(fid,1,'*float32',byteorder);
vertical_zoom_scale_factor = fread(fid,1,'*double',byteorder);
vertical_zoom_position = fread(fid,1,'*float32',byteorder);
waveform_label = char(fread(fid,32,'*char',byteorder)');
N = fread(fid,1,'*uint32',byteorder);
size_of_waveform_header = fread(fid,1,'*uint16',byteorder);

%read waveform header
setType = fread(fid,4,'*int8',byteorder); 
wfmCnt = fread(fid,1,'*uint32',byteorder); 
fread(fid,24,'char',byteorder); %skip bytes 86 to 109 (not for use)
wfm_update_spec_count = fread(fid,1,'*uint32',byteorder); 
imp_dim_ref_count = fread(fid,1,'*uint32',byteorder); 
exp_dim_ref_count = fread(fid,1,'*uint32',byteorder); 
data_type = fread(fid,4,'*int8',byteorder);  
fread(fid,16,'char',byteorder); %skip bytes 126 to 141 (not for use)
curve_ref_count = fread(fid,1,'*uint32',byteorder);
num_req_fast_frames = fread(fid,1,'*uint32',byteorder);
num_acq_fast_frames = fread(fid,1,'*uint32',byteorder);
%There's a misprinting in the SDK article, the ":" at the beginning of version number string is missing.
%read optional entry in WFM#002 (and higher?) file format:
if sscanf(versioning_number,':WFM#%3d')>1 % see footnote 6 in SDK Article concerning TDS5000B scopes and version number 002
   summary_frame_type = fread(fid,1,'*uint16',byteorder);
end                                       
pixmap_display_format = fread(fid,4,'*int8',byteorder); 
pixmap_max_value = fread(fid,1,'uint64',byteorder); %storage in a uint64 variable does not work. Uses only double. Bug in Matlab?

%explicit dimension 1
ed1.dim_scale = fread(fid,1,'*double',byteorder);
ed1.dim_offset = fread(fid,1,'*double',byteorder);
ed1.dim_size = fread(fid,1,'*uint32',byteorder);
dummy=fread(fid,20,'*char',byteorder);
ed1.units = char(dummy(1:find(dummy==0)));         %read units until NULL string (suggested by Tom Gaudette)
ed1.dim_extent_min = fread(fid,1,'*double',byteorder);
ed1.dim_extent_max = fread(fid,1,'*double',byteorder);
ed1.dim_resolution = fread(fid,1,'*double',byteorder);
ed1.dim_ref_point = fread(fid,1,'*double',byteorder);
ed1.format = fread(fid,4,'*int8',byteorder);
ed1.storage_type = fread(fid,4,'*int8',byteorder); 
ed1.n_value = fread(fid,1,'*int32',byteorder);
ed1.over_range = fread(fid,1,'*int32',byteorder);
ed1.under_range = fread(fid,1,'*int32',byteorder);
ed1.high_range = fread(fid,1,'*int32',byteorder);
ed1.low_range = fread(fid,1,'*int32',byteorder);
ed1.user_scale = fread(fid,1,'*double',byteorder);
ed1.user_units = char(fread(fid,20,'*char',byteorder)');
ed1.user_offset = fread(fid,1,'*double',byteorder);
if version3
    ed1.point_density = fread(fid,1,'*double',byteorder);
else
    ed1.point_density = fread(fid,1,'*uint32',byteorder);
end

ed1.href = fread(fid,1,'*double',byteorder);
ed1.trig_delay = fread(fid,1,'*double',byteorder);

%explicit dimension 2
ed2.dim_scale = fread(fid,1,'*double',byteorder);
ed2.dim_offset = fread(fid,1,'*double',byteorder);
ed2.dim_size = fread(fid,1,'*uint32',byteorder);
dummy=fread(fid,20,'*char',byteorder);
ed2.units = char(dummy(1:find(dummy==0)));         %read units until NULL string (suggested by Tom Gaudette)
ed2.dim_extent_min = fread(fid,1,'*double',byteorder);
ed2.dim_extent_max = fread(fid,1,'*double',byteorder);
ed2.dim_resolution = fread(fid,1,'*double',byteorder);
ed2.dim_ref_point = fread(fid,1,'*double',byteorder);
ed2.format = fread(fid,4,'*int8',byteorder);
ed2.storage_type = fread(fid,4,'*int8',byteorder); 
ed2.n_value = fread(fid,1,'*int32',byteorder);
ed2.over_range = fread(fid,1,'*int32',byteorder);
ed2.under_range = fread(fid,1,'*int32',byteorder);
ed2.high_range = fread(fid,1,'*int32',byteorder);
ed2.low_range = fread(fid,1,'*int32',byteorder);
ed2.user_scale = fread(fid,1,'*double',byteorder);
ed2.user_units = char(fread(fid,20,'*char',byteorder)');
ed2.user_offset = fread(fid,1,'*double',byteorder);
if version3
    ed2.point_density = fread(fid,1,'*double',byteorder);
else
    ed2.point_density = fread(fid,1,'*uint32',byteorder);
end
ed2.href = fread(fid,1,'*double',byteorder);
ed2.trig_delay = fread(fid,1,'*double',byteorder);

%implicit dimension 1
id1.dim_scale = fread(fid,1,'*double',byteorder);
id1.dim_offset = fread(fid,1,'*double',byteorder);
id1.dim_size = fread(fid,1,'*uint32',byteorder);
id1.units = char(fread(fid,20,'*char',byteorder)');
id1.dim_extent_min = fread(fid,1,'*double',byteorder);
id1.dim_extent_max = fread(fid,1,'*double',byteorder);
id1.dim_resolution = fread(fid,1,'*double',byteorder);
id1.dim_ref_point = fread(fid,1,'*double',byteorder);
id1.spacing = fread(fid,1,'*uint32',byteorder);
id1.user_scale = fread(fid,1,'*double',byteorder);
id1.user_units = char(fread(fid,20,'*char',byteorder)');
id1.user_offset = fread(fid,1,'*double',byteorder);
if version3
    id1.point_density = fread(fid,1,'*double',byteorder);
else
    id1.point_density = fread(fid,1,'*uint32',byteorder);
end
id1.href = fread(fid,1,'*double',byteorder);
id1.trig_delay = fread(fid,1,'*double',byteorder);

%implicit dimension 2
id2.dim_scale = fread(fid,1,'*double',byteorder);
id2.dim_offset = fread(fid,1,'*double',byteorder);
id2.dim_size = fread(fid,1,'*uint32',byteorder);
id2.units = char(fread(fid,20,'*char',byteorder)');
id2.dim_extent_min = fread(fid,1,'*double',byteorder);
id2.dim_extent_max = fread(fid,1,'*double',byteorder);
id2.dim_resolution = fread(fid,1,'*double',byteorder);
id2.dim_ref_point = fread(fid,1,'*double',byteorder);
id2.spacing = fread(fid,1,'*uint32',byteorder);
id2.user_scale = fread(fid,1,'*double',byteorder);
id2.user_units = char(fread(fid,20,'*char',byteorder)');
id2.user_offset = fread(fid,1,'*double',byteorder);
if version3
    id2.point_density = fread(fid,1,'*double',byteorder);
else
    id2.point_density = fread(fid,1,'*uint32',byteorder);
end
id2.href = fread(fid,1,'*double',byteorder);
id2.trig_delay = fread(fid,1,'*double',byteorder);

%time base 1
tb1_real_point_spacing = fread(fid,1,'*uint32',byteorder);
tb1_sweep = fread(fid,4,'*int8',byteorder); 
tb1_type_of_base = fread(fid,4,'*int8',byteorder); 

%time base 2
tb2_real_point_spacing = fread(fid,1,'*uint32',byteorder);
tb2_sweep = fread(fid,4,'*int8',byteorder); 
tb2_type_of_base = fread(fid,4,'*int8',byteorder); 

%wfm update specicfication
real_point_offset = fread(fid,1,'*uint32',byteorder);
tt_offset = fread(fid,1,'*double',byteorder);
frac_sec = fread(fid,1,'*double',byteorder);
GMT_sec = fread(fid,1,'*int32',byteorder);

%wfm curve information
state_flags = fread(fid,1,'*int32',byteorder); 
%There's a misprinting in the SDK article here:
%The field type of "state_flags" is "long" (4 bytes) instead of "double" (8 bytes)
%The offset values starting from 820 ("end of curve buffer offset") are printed incorrectly, too.
type_of_checksum = fread(fid,4,'*int8',byteorder); 
checksum = fread(fid,1,'*int16',byteorder); 
precharge_start_offset = fread(fid,1,'*uint32',byteorder);
data_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
postcharge_start_offset = fread(fid,1,'uint32',byteorder); %do not convert to same type, since required as double later
postcharge_stop_offset = fread(fid,1,'*uint32',byteorder);
end_of_curve_buffer_offset = fread(fid,1,'*uint32',byteorder);

%In this first version of wfm2read I omit the implementation of fast frames and other complicated stuff and jump directly to the curve buffer
offset = double(byte_offset_to_beginning_of_curve_buffer+data_start_offset);

switch ed1.format(1)
    case 0 
        format='*int16';
    case 1 
        format='*int32';
    case 2 
        format='*uint32';
    case 3 
        format='*uint64';  %may not work properly. Bug in Matlab? Does not convert to uint64, but to double instead. 
    case 4 
        format='*float32';
    case 5 
        format='*float64';
    otherwise
        error(['invalid data format or error in file ' filename]);
end

%read the curve buffer portion which is displayed on the scope only 
%(i.e. drop precharge and postcharge points)
nop=(postcharge_start_offset-data_start_offset)/num_bytes_per_point; %number of data points
if nargin==2
    nop = min(nop, datapoints); % take only as many data points as set by optional input parameter, or all of them if datapoints is larger than number of data points in file 
end
fseek(fid, offset,'bof');
values=double(fread(fid,nop,format,byteorder));%read data values from curve buffer
%handling over- and underranged values
ind_over=find(values==ed1.over_range); %find indices of values that are larger than the AD measurement range (upper limit)
ind_under=find(values<=-ed1.over_range);%find indices of values that are larger than the AD measurement range (lower limit)
y = ed1.dim_offset + ed1.dim_scale *values;  %scale data values to obtain in correct units 
fclose(fid);
%t = id1.dim_offset + id1.dim_scale * (1:nop)';
t =id1.dim_offset+id1.dim_scale*transpose(0:(nop-1));

info.yunit = ed1.units;
info.tunit = id1.units;
info.yres = ed1.dim_resolution;
info.samplingrate = 1/id1.dim_scale;
info.nop = nop;

%print warning if there are wrong values because they are lying outside 
%the AD converter digitization window:
if length(ind_over)
   warning([int2str(length(ind_over)), ' over range value(s) in file ' filename]);
end
if length(ind_under)
   warning([int2str(length(ind_under)), ' under range value(s) in file ' filename]);
end

end