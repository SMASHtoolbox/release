function [signal,varargout]=read_nts(filename)

if (nargin<1) || isempty(filename)
    [fname,pname]=uigetfile(...
        {'*.dig;*.DIG','DIG files'},...
        'Select DIG file');
    filename=fullfile(pname,fname);
end
info.filename=filename;

% verify file
if exist(filename,'file')~=2
    error('ERROR: invalid file name specified');
end

% open file and skip unused header
fid=fopen(filename,'rb');
info.preamble=fread(fid,512,'char');
info.preamble=transpose(char(info.preamble));

info.user=fread(fid,256,'uchar');
info.user=transpose(char(info.user));

% read plot auxillary area
info.system=fgetl(fid);
info.timestamp=fgetl(fid);
info.record_size=fscanf(fid,'%g',1);
info.word_size=fscanf(fid,'%g',1);
info.dT=fscanf(fid,'%g',1);
info.T1=fscanf(fid,'%g',1);
info.dV=fscanf(fid,'%g',1);
info.V0=fscanf(fid,'%g',1);
switch info.word_size
    case 8
        precision='uint8';
    case 16
        precision='uint16';
    case 32
        precision='uint32';
    case 64
        precision='uint64';
    otherwise
        error('ERROR: dig file specifies invalid word size');
end

% read data
offset=1024;
fseek(fid,offset,'bof');
signal=fread(fid,info.record_size,precision);
fclose(fid);

% apply plot auxillary data
signal=info.dV*signal+info.V0;

% generate optional outputs
if nargout>=2
    time=transpose(0:(info.record_size-1));
    time=info.dT*time+info.T1;
    varargout{1}=time;
end

if nargout>=3
    varargout{2}=info;    
end