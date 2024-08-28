% write Write data to a PFF object
%
%     >> write(object,data);
% UNDER CONSTRUCTION!
%
% See also PFFfile
%

%
% 
%
function write(object,data,mode)

% manage input
assert(nargin>=2,'ERROR: insufficient input');
assert(isstruct(data) && (numel(data)==1),...
    'ERROR: data must be passed in an individual structure');

dataset=struct(...
    'Type','(Type)','Title','(Label)',...
    'X',[],'XLabel','(XLabel)',...
    'Y',[],'YLabel','(YLabel)',...
    'Z',[],'ZLabel','(ZLabel)',...
    'Data',0,'DataLabel','(DataLabel)');
% NaN can't be used!
name=fieldnames(data);
for k=1:numel(name)
    if isfield(dataset,name{k})
        dataset.(name{k})=data.(name{k});
    else
        fprintf('Ignoring unrecognized filed "%s"\n',name{k});
    end
end

if (nargin<3) || isempty(mode)
    %mode='append';
    mode='create';
    %mode='overwrite';
end
assert(ischar(mode),'ERROR: invalid mode requested')
mode=lower(mode);
switch mode
    case {'create','append','overwrite'}
        % do nothing
    otherwise
        error('ERROR: invalid mode requested');
end

% verify dataset
[LY,LX,LZ]=size(dataset.Data);

NX=numel(dataset.X);
if NX==0
    dataset.NX=1;
    dataset.X=0;
else
    dataset.NX=NX;
    dataset.X=dataset.X(:);
end
assert(dataset.NX==LX,'ERROR: X array is incompatible with the Data array');


NY=numel(dataset.Y);
if NY==0
    dataset.NY=1;
    dataset.Y=0;
else
    dataset.NY=NY;
   dataset.Y=dataset.Y(:); 
end
assert(dataset.NY==LY,'ERROR: Y array is incompatible with the Data array');

NZ=numel(dataset.Z);
if NZ==0
    dataset.NZ=1;
    dataset.Z=0;
else
    dataset.NZ=NZ;
    dataset.Z=dataset.Z(:);
end
assert(dataset.NZ==LZ,'ERROR: Z array is incompatible with the Data array');

% create file handle
if exist(object.FullName,'file')
    switch mode
        case 'create'
            error('ERROR: file already exists');
        case 'overwrite'
            delete(object.FullName);
    end
    strcmp(mode,'overwrite')
end
fid=fopen(object.FullName,'w+','ieee-be');
CleanObject=onCleanup(@() fclose(fid)); % automatically close file on function exit

% create file header
WriteWord(fid,-4); % FFRAME
DEFAULT=-3;
for k=2:16
    WriteWord(fid,DEFAULT);
end

% create dataset header
start=ftell(fid);
WriteWord(fid,-1); % DFRAME (start word)
WriteLong(fid,0); % LDS placeholder
WriteWord(fid,3); % TRAW (PFTNF3)
WriteWord(fid,DEFAULT); % VDS
WriteWord(fid,3); % TAPP
for k=1:10 % RFU
    if k==1
        WriteWord(fid,1);
    else
        WriteWord(fid,DEFAULT);
    end
end
WriteString(fid,dataset.Type);
WriteString(fid,dataset.Title);

% create dataset
WriteWord(fid,1); % NBLOCKS
WriteLong(fid,dataset.NX);
WriteLong(fid,dataset.NY);
WriteLong(fid,dataset.NZ);
for k=1:5 % ISPARE
    WriteWord(fid,DEFAULT);
end
WriteFloatArray(fid,dataset.X);
WriteFloatArray(fid,dataset.Y);
WriteFloatArray(fid,dataset.Z);
WriteString(fid,dataset.XLabel);
WriteString(fid,dataset.YLabel);
WriteString(fid,dataset.ZLabel);
WriteString(fid,dataset.DataLabel);
WriteFloatArray(fid,dataset.Data);

% finish dataset and revise the header
stop=ftell(fid);
WriteWord(fid,-2); % stop word
fseek(fid,start+2,'bof'); % move to LDS location
LDS=stop-start;
%fprintf('LDS=%g bytes, %g words\n',LDS,LDS/2);
WriteLong(fid,LDS/2); % LDS (words)
% leave file header "broken"

end