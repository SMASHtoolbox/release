% UNDER CONSTRUCTION
% convertData Convert data file
%
% This *static* method converts a data file to a binary format for use
% with the LongSignal class.
%    LongSignal.convertData(name,format,record);


function convertData(file,format,record,varargin)

% manage input
if (nargin < 1) || isempty(file)
    [file,location]=uigetfile('*.*','Select data file');
    if isenumeric(file)
        return
    end
    file=fullfile(location,file);
else
    assert(ischar(file),'ERROR: invalid data file name');
    assert(logical(exist(file,'file')),'ERROR: data file not found');
end

if (nargin < 2) || isempty(format)
    try
        format=SMASH.FileAccess.determineFormat(file);
    catch
        return
    end
else
    assert(ischar(format),'ERROR: invalid file format');
    match=false;
    list=SMASH.FileAccess.SupportedFormats();
    for k=1:numel(list)
        if strcmpi(format,list{k})
            match=true;
            break
        end
    end
    assert(match,'ERROR: unsupported file format');
end

if nargin < 3
    record=[];
end

% manage options
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
option.Chunk=200000;
option.Deflate=5;
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'chunk'
            assert(SMASH.General.testNumber(value,'integer','positive','notzero'),...
                'ERROR: invalid chunk value');
            option.Chunk=value;
        case 'deflate'
            allowed=0:9;
            assert(isnumeric(value) && isscalar(value) && any(value == allowed),...
                'ERROR: invalid deflate value');
            option.Deflate=value;
        otherwise
            error('ERROR: "%s" is not a valid option');
    end
end

% generate unique conversion file
[~,short]=fileparts(file);
index=1;
while true
    target=sprintf('%s_conversion%d.h5',short,index);
    if exist(target,'file')
        index=index+1;
        continue
    else
        break
    end
end

fid=fopen(target,'w');
fclose(fid);
h5writeatt(target,'/','Description','/Signal contains data channels (columns) on a uniformly spaced grid.');

% convert data
switch lower(format)
    case {'agilent' 'keysight'}
        convertKeysight(file,record,target,option);
    %case 'tektronix'
        
    %case 'lecroy'
        
    %case 'column'
        
    otherwise
        error('ERROR: ''%s'' format not currently supported',format);        
end

end