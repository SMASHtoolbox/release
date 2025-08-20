% UNDER CONTRUCTION

% *.spe
% *.hdf

function data=readFile(source)

data=struct();
if nargin < 1
    location=uigetfile({'*.*' 'All files'},'Select image file');
    if isnumeric(location)       
        return
    end
else
    assert(ischar(source),'ERROR: invalid file name');    
    if contains(source,'*')
        file=dir(source);
        for n=1:numel(file)
            source=fullfile(file(n).folder,file(n).name);
            new=packtools.call('GatedCamera.readFile',source);
            if n == 1
                data=repmat(new,size(file));
            else
                data(n)=new;
            end
        end
        return
    end
end
data.Info=struct();

% generic image file
try %#ok<TRYNC>
    data.Frame.Data=imread(source);    
    return
end

% Princeton Instruments WinSpec file
try %#ok<TRYNC>
    raw=SMASH.FileAccess.readFile(source,'winspec');
    data.Frame=raw.Data;
    return
end

% Sydor multi-frame files 
try %#ok<TRYNC>
    data=readSydor(source);
    return
end
       
end

%%
function data=readSydor(file)

[~,~,ext]=fileparts(file);
assert(strcmpi(ext,'.hdf'),'Invalid file extension');
content=hdfinfo(file);
assert(isfield(content,'SDS'),'No scientific dataset found');

M=numel(content.SDS);
for m=1:M   
    record=content.SDS(m);
    info=struct();
    for n=1:numel(record.Attributes)
        name=record.Attributes(n).Name;
        value=record.Attributes(n).Value;
        info.(name)=value;
    end
    raw=double(hdfread(file,record.Name));    
    new=struct('Info',info,'RawData',raw);
    if m == 1
       data=repmat(new,[M 1]);
    else
        data(m)=new;
    end
end

end