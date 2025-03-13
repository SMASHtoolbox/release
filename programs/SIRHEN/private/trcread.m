% TRCREAD Read LeCroy binary data files
%
% This function reads binary data created by LeCroy digitizers
% (*.TRC files).  To access the signal and its time base, call the function
% with a file name as an input.
%   >> [signal,time]=trcread(filename);
% If no file is specified, the user will be prompted to select one.  To
% obtain additional information about the file, use a third output
% argument.
%   >> [signal,time,info]=trcread(...);
%

% created August 17, 2013 by Daniel Dolan (Sandia National Laboratories)
function varargout=trcread(filename)

% handle input
if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile('*.trc;*.TRC','Choose LeCroy TRC file');
    if isnumeric(fname) % user pressed cancel
        varargout{1}=fname;
        return
    end
    filename=[pname fname];    
end

% read file
machineformat='ieee-le';
fid=fopen(filename,'r',machineformat);

target='WAVEDESC';
while ~feof(fid)
    temp=fscanf(fid,'%8c',1);
    if strcmp(temp,target)
        fseek(fid,-numel(target),'cof');
        %start=ftell(fid);
        info.descriptor_name=ReadString;
        break
    else
        fseek(fid,-numel(target)+1,'cof');
    end
end
info.template_name=ReadString;
info.comm_type=InterpretCommType(ReadEnum);
[info.comm_order,machineformat]=InterpretCommOrder(ReadEnum);

info.wave_descriptor=ReadLong;
info.user_text=ReadLong;
info.res_desc1=ReadLong;
info.trigtime_array=ReadLong;
info.ris_time_array=ReadLong;
info.res_array1=ReadLong;
info.wave_array_1=ReadLong;
info.wave_array_2=ReadLong;
info.res_array2=ReadLong;
info.res_array3=ReadLong;
info.instrument_name=ReadString;
info.instrument_number=ReadLong;
info.trace_label=ReadString;
info.reserved1=ReadWord;
info.reserved2=ReadWord;

info.wave_array_count=ReadLong;
info.pnts_per_screen=ReadLong;
info.first_valid_pnt=ReadLong;
info.last_valid_pnt=ReadLong;
info.first_point=ReadLong;
info.sparsing_factor=ReadLong;
info.segment_index=ReadLong;
info.subarray_count=ReadLong;
info.sweeps_per_acq=ReadLong;
info.points_per_pair=ReadWord;
info.pair_offset=ReadWord;
info.vertical_gain=ReadFloat;
info.vertical_offset=ReadFloat;
info.max_value=ReadFloat;
info.min_value=ReadFloat;
info.nominal_bits=ReadWord;
info.nominal_subarray_count=ReadWord;
info.horiz_interval=ReadFloat;
info.horiz_offset=ReadDouble;
info.pixel_offset=ReadDouble;
info.vertunit=ReadUnitDefinition;
info.horzunit=ReadUnitDefinition;
info.horiz_uncertainty=ReadFloat;
info.trigger_time=ReadTimeStamp;
info.acq_duration=ReadFloat;
info.record_type=InterpretRecordType(ReadEnum);
info.process_done=InterpretProcessingDone(ReadEnum);
info.reserved5=ReadWord;
info.ris_sweeps=ReadWord;

info.timebase=InterpretTimebase(ReadEnum);
info.vert_coupling=InterpretVerticalCoupling(ReadEnum);
info.probe_att=ReadFloat;
info.fixed_vert_gain=InterpretFixedVerticalGain(ReadEnum);
info.bandwidth_limit=InterpretBandwidthLimit(ReadEnum);
info.vertical_vernier=ReadFloat;
info.acq_vert_offset=ReadFloat;
info.wave_source=InterpretWaveSource(ReadEnum);

if info.user_text>0
    format=sprintf('%%%dc',info.user_text);
    info.user_text_block=fscanf(fid,format,1);
end

if info.trigtime_array>0
    % under construction
end

if info.ris_time_array>0
    % under construction
end

switch info.comm_type
    case 'byte'
        signal=ReadByte(info.pnts_per_screen);
    case 'word'
        signal=ReadWord(info.pnts_per_screen);
end

%fprintf('offset=%d\n',ftell(fid)-start);
fclose(fid);

%% entry readers
    function result=ReadString()
        result=fscanf(fid,'%16c',1);
    end
    function result=ReadByte(repeat)
        if nargin<1
            repeat=1;
        end
        result=fread(fid,repeat,'int8',machineformat);        
    end
    function result=ReadWord(repeat)        
        if nargin<1
            repeat=1;
        end
        result=fread(fid,repeat,'int16',machineformat);        
    end
    function result=ReadLong()        
        result=fread(fid,1,'int32',machineformat);        
    end
    function result=ReadEnum()
        result=fread(fid,1,'int16',machineformat); 
    end
    function result=ReadFloat()
        result=fread(fid,1,'single',machineformat);
    end
    function result=ReadDouble()
        result=fread(fid,1,'double',machineformat);
    end
    function result=ReadTimeStamp()
        second=ReadDouble;
        minute=ReadByte;
        hour=ReadByte;
        day=ReadByte;
        month=ReadByte;
        year=ReadWord;
        ReadWord; % unused
        result=datenum(year,month,day,hour,minute,second);
        result=datestr(result);
    end
    function result=ReadUnitDefinition()
        result=fscanf(fid,'%48c',1);
    end

%% calcuate time and signal arrays
time=0:(info.pnts_per_screen-1);
time=time*info.horiz_interval+info.horiz_offset;

signal=signal*info.vertical_gain-info.vertical_offset;
time=reshape(time,size(signal));

%% handle output
if nargout==0
    figure;
    plot(time,signal);
end

if nargout>=1
    varargout{1}=signal;
end

if nargout>=2
    varargout{2}=time;
end

if nargout>=3
    varargout{3}=info;
end

end

%% interpreters
function result=InterpretCommType(value)

switch value
    case 0
        result='byte';
    case 1
        result='word';
end

end

function [result,machineformat]=InterpretCommOrder(value)

switch value
    case 0
        result='HIFIRST';
        machineformat='ieee-be'; % big endian
    case 1
        result='LOFIRST';
        machineformat='ieee-le'; % little endian
end

end

function result=InterpretRecordType(value)

switch value
    case 0
        result='single_sweep';
    otherwise
        result=value;
end

end

function result=InterpretProcessingDone(value)

switch value
    case 0
        result='no_processing';
    case 1
        result='fir_filter';
    case 2
        result='interpolated';
    case 3
        result='sparsed';
    case 4
        result='autoscaled';
    case 5
        result='no_result';
    case 6
        result='rolling';
    case 7
        result='cumulative';
    otherwise
        result=value;
end

end

function result=InterpretTimebase(value)

if value==100
    result='external';
    return
end

factor=floor(value/3);
extra=value-3*factor;
if extra==0
    result=1;
elseif extra==1
    result=2;
elseif extra==2
    result=5;
end
result=result*10^(factor)*1e-12; % second per division

end

function result=InterpretVerticalCoupling(value)

switch value
    case 0
        result='DC_50_Ohms';
    case 1
        result='ground';
    case 2
        result='DC_1MOhm';
    case 3
        result='ground';
    case 4
        result='AC_1MOhm';
end

end

function result=InterpretFixedVerticalGain(value)

factor=floor(value/3);
extra=value-3*factor;
if extra==0
    result=1;
elseif extra==1
    result=2;
elseif extra==2
    result=5;
end
result=result*10^(factor)*1e-6; % volts per division

end

function result=InterpretBandwidthLimit(value)

switch value
    case 0
        result='off';
    case 1
        result='on';
end

end

function result=InterpretWaveSource(value)

switch value
    case 0
        result='CHANNEL_1';
    case 1
        result='CHANNEL_2';
    case 2
        result='CHANNEL_3';
    case 3
        result='CHANNEL_4';
    case 9
        result='UNKNOWN';
end

end