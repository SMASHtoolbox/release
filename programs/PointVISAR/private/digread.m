% digread : Read DIG binary files
%
% Usage:
%   [signal,time,info]=digread(filename);
%
% If the no input is specified, the user will be prompted for a file name
% by a dialog box.  The signal and its time base are stored as 1D arrays in
% the first two outputs (respectively).  Additional information is returned
% as a structure in the third argument (optional). 
%

% created September 25, 2008 by Daniel Dolan at Sandia National Labs
function [signal,time,info]=digread(filename)

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
offset=768; % 0x0300 (hex)
fseek(fid,offset,'bof');

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
        format='uint8';
    case 16
        format='uint16';
    case 32
        format='uint32';
    case 64
        format='uint64';
end

% read data
offset=1024; % 0x0400 (hex)
fseek(fid,offset,'bof');
signal=fread(fid,info.record_size,format);
fclose(fid);

% apply plot auxillary data
signal=info.dV*signal+info.V0;
time=transpose(1:info.record_size);
time=info.dT*(time-1)+info.T1;