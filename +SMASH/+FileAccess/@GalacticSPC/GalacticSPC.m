% GalacticSPC Galactic SPC class 
%
% This *prototype* class accesses Galactic Industries *.spc files.
% 
% See also SMASH.FileAccess
%
classdef GalacticSPC < SMASH.Developer.SimpleHandle
    %%
    properties (SetAccess=protected)
        File
        Flag
        Format
        Information
    end
    properties (SetAccess=protected)
        StartByte
    end
    %%
    methods (Hidden=true)
        function object=GalacticSPC(file)           
            ERRMSG='ERROR: cannot create object without valid SPC file';
            % manage input
            if (nargin < 1) || isempty(file)
                [name,location]=uigetfile(...
                    {'*.spc;*.SPC' 'Galactic *.spc files'},...
                    'Select file');
                assert(~isnumeric(name),ERRMSG);
                file=fullfile(location,name);
            else
                assert(ischar(file) && isfile(file),ERRMSG);
                [~,~,ext]=fileparts(file);
                assert(strcmpi(ext,'.spc'),ERRMSG);
            end           
            object.File=file;
            % read header
            fid=fopen(file,'r');
            CU=onCleanup(@() fclose(fid));
            value=dec2bin(fread(fid,1,'uint8'),8);
            list={'TSPREC' 'TCGRAM' 'TMULTI' 'TORDRD' 'TALABS' 'TXYXYS' 'TXVALS'};
            for k=2:8
                if value(k) == '1'
                    object.Flag.(list{k-1})=true;
                else
                    object.Flag.(list{k-1})=false;
                end
            end
            object.Format=dec2hex(fread(fid,1,'uint8'));
            switch object.Format
                case {'4B' '4C'}
                    error('New formats not supported yet');           
                case '4D'
                    scanOld(object,fid);
                otherwise
                    error(ERRMSG);
            end            
        end
    end
end

function scanOld(object,fid)

% main header
data.Exponent=fread(fid,1,'uint16');
data.NumPoints=fread(fid,1,'single');
data.FirstPoint=fread(fid,1,'single');
data.LastPoint=fread(fid,1,'single');

data.XUnit='Arbitrary';
value=fread(fid,1,'uint8');
switch value
    case 0
    case 1
        data.XUnit='Wavenumber (1/cm)';
    otherwise
        warning('Xtype %d not yet recognized',value);
end

data.YUnit='Arbitrary';
value=fread(fid,1,'uint8');
switch value
    case 0
    otherwise
        warning('Ytype %d not yet recognized',value);
end

year=fread(fid,1,'uint16');
temp=fread(fid,4,'uint8');
data.Date=sprintf('%04d-%02d-%02d %02d:%02d',year,temp);

data.Resolution=strtrim(fread(fid,8,'*char')');
data.PeakPoint=fread(fid,1,'uint16');
data.NumScans=fread(fid,1,'uint16');
data.Spare=fread(fid,7,'single');
data.Comment=deblank(fread(fid,130,'*char')');
data.CaText=deblank(fread(fid,30,'*char')');

% subheader
%data.SubFlag=fread(fid,1,'uint8');
%data.SubExp=fread(fid,1,'char');
%data.SubIndex=fread(fid,1,'uint16');
object.StartByte=256;
%object.StartByte=288;
%object.StartByte=512;

%
object.Information=data;


end
