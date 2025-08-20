% RefractiveIndex Refractive index data
%
% This function accesses data obtained from refractiveindex.info.  Users
% must first download the data library from https://refractiveindex.info/about.
% That library must be initialized before it can be used.
%    RefractiveIndex('initialize',location);
% Optional input "location" indicates the local folder containing the file
% 'catalog-nk.yml' and the subdirectory 'data-nk'.  Omitting the location
% prompts interactive folder selection.  The library location is stored
% between MATLAB session.
% 
% After initialization, calling this function with no inputs:
%    data=RefractiveIndex();
% allows interactive selection of one table entry.  Entries can also be
% requested with name/source matching patterns.
%    data=RefractiveIndex('Name',pattern);
%    data=RefractiveIndex('Source',pattern);
% Combining multiple patterns narrows the search to entries that match
% *all* requested criteria.  NOTE: patterns are matched in a case-sensitive
% manner.
%
% The output "data" is a structure array containing all matching library
% entries.  Field names include Name, Source, Header, Table, and Footer.
% Usually Table is the field of interest, but some entries list only
% Sellmeir coefficients that show up in the header.
%
% See also SMASH.Reference
%
function data=RefractiveIndex(varargin)

% initialization
if (nargin >= 1) && strcmpi(varargin{1},'initialize')
    if nargin < 2
        LibraryLocation=uigetdir(pwd,'Select library location');
        assert(~isnumeric(LibraryLocation),...
            'ERROR: no library location selected');
    else
       LibraryLocation=varargin{2}; 
       assert(isfolder(LibraryLocation),'ERROR: invalid library location');
    end
    setpref('SMASH','RefractiveIndex',LibraryLocation);
    return
else
    try
        LibraryLocation=getpref('SMASH','RefractiveIndex');
        assert(~isempty(LibraryLocation),'');
    catch
        error('ERROR: library not initialized');
    end
end

% load table
persistent LibraryTable
if isempty(LibraryTable)    
    try
        LibraryTable=parseLibrary();
    catch
        error('ERROR: unable to parse library--please reinitialize the library');
    end
end

% manage input
if (nargin == 0)    
    data=selectEntry(LibraryTable);
else
    data=matchEntry(LibraryTable,varargin{:});
end

% read file(s)
N=numel(data);
for n=1:N
    temp=fullfile(LibraryLocation,'data-nk',data(n).File);
    assert(isfile(temp),...
        'ERROR: data file not found--please reinitialize the library');
    temp=readData(temp);
    name=fieldnames(temp);
    for k=1:numel(name)
        data(n).(name{k})=temp.(name{k});
    end
end

end

%% read data from library file
function out=readData(file)

fid=fopen(file,'r','native','UTF-8');
CU=onCleanup(@() fclose(fid));

header={};
data=[];
footer={};
while ~feof(fid)
    position=ftell(fid);
    temp=strtrim(fgetl(fid));
    if isempty(temp) || (temp(1) == '#')
        continue
    elseif ~isempty(data)
        footer{end+1}=temp; %#ok<AGROW>
        continue
    end    
    [~,N,~,next]=sscanf(temp,'%g');
    if isempty(temp(next:end))
        fseek(fid,position,'bof');
        format=repmat('%g',[1 N]);
        data=fscanf(fid,format,[N inf]);
        data=transpose(data);
    else
        header{end+1}=temp; %#ok<AGROW>
    end
end

out.Header=sprintf('%s\n',header{:});
out.Table=data;
out.Footer=sprintf('%s\n',footer{:});

end

%% parse refractive index library
function library=parseLibrary(varargin)

location=getpref('SMASH','RefractiveIndex');
file=fullfile(location,'catalog-nk.yml');
fid=fopen(file,'r','native','UTF-8');
CU=onCleanup(@() fclose(fid));

Shelf='';
Book='';
library=[];
while ~feof(fid)
    temp=fgetl(fid);
    if isempty(strtrim(temp)) || (temp(1) == '#')
        continue
    end
    [name,value]=splitText(temp);
    if strcmp(name,'- SHELF')
        Shelf=value;               
    elseif strcmp(name,'- BOOK')
        Book=value;
        BookName='';
        while isempty(BookName)
            temp=fgetl(fid);
            [name,value]=splitText(temp);
            if strcmp(name,'name')
                BookName=value(2:end-1);
            end
        end
    elseif strcmp(name,'- PAGE')
        PageName='';
        PageData='';        
        while isempty(PageName) || isempty(PageData)
            temp=fgetl(fid);
            [name,value]=splitText(temp);
            if strcmp(name,'name')
                PageName=value(2:end-1);
            elseif strcmp(name,'data')
                PageData=value(2:end-1);
            end
        end
        temp=struct(...
             'Shelf',Shelf,...
             'Book',Book,'BookName',BookName,...
             'PageName',PageName,'PageData',PageData); 
         if isempty(library)
             library=temp; 
         else
             library(end+1)=temp; %#ok<AGROW>
         end
    else
        continue
    end        
end

library=struct2table(library);

end

%% split text
function [name,value]=splitText(data)

index=strfind(data,':');
index=index(1);
name=strtrim(data(1:index-1));
value=strtrim(data(index+1:end));

end

%% select library entry
function result=selectEntry(LibraryTable)

shelf=LibraryTable{:,1};
material=LibraryTable{:,3};
source=LibraryTable{:,4};
file=LibraryTable{:,5};

db=SMASH.MUI.Dialog('FontSize',12);
db.Hidden=true;
db.Name='Select material';

value=1;
list=unique(shelf);
for m=1:numel(list)
    if strcmp(list{m},'main')
        value=m;
        break
    end
end

hShelf=addblock(db,'popup','Shelf:',list,40);
set(hShelf(1),'FontWeight','bold');
set(hShelf(2),'Value',value,'Callback',@changeShelf);
    function changeShelf(varargin)
        choice=get(hShelf(end),'String');
        k=get(hShelf(end),'Value');      
        choice=choice{k};               
        N=numel(shelf);
        keep=false(N,1);
        for n=1:N
            if strcmp(shelf{n},choice)
                keep(n)=true;
            end
        end
        list=unique(material(keep));
        set(hMaterial(end),'String',list,'Value',1);
        changeMaterial();
    end

dummy={'dummy'};
hMaterial=addblock(db,'popup','Material:',dummy,40);
set(hMaterial(1),'FontWeight','bold');
set(hMaterial(2),'Callback',@changeMaterial);
    function changeMaterial(varargin)
        choice=get(hMaterial(end),'String');
        k=get(hMaterial(end),'Value');
        choice=choice{k};        
        N=numel(material);
        keep=false(N,1);
        for n=1:N
            if strcmp(material{n},choice)
                keep(n)=true;
            end
        end
        set(hSource(end),'String',source(keep),'Value',1,...
            'UserData',file(keep));
    end

hSource=addblock(db,'popup','Source:',dummy,40);
set(hSource(1),'FontWeight','bold');

button=addblock(db,'button','Done');
set(button,'Callback',@done)
    function done(varargin)
        delete(button);
    end

changeShelf();
locate(db,'center');
show(db);

waitfor(button);
if isvalid(db)
    list=get(hMaterial(end),'String');
    value=get(hMaterial(end),'Value');
    result.Name=list{value};
    list=get(hSource(end),'String');
    value=get(hSource(end),'Value');
    result.Source=list{value};    
    list=get(hSource(end),'UserData');
    value=get(hSource(end),'Value');
    result.File=list{value};    
    delete(db);
else
    error('ERROR: no source selected');
end

end

%% match library entry
function result=matchEntry(LibraryTable,varargin)

Narg=numel(varargin);
errmsg='ERROR: invalid search request';
assert(rem(Narg,2) == 0,errmsg);
for n=1:2:Narg
    assert(ischar(varargin{n}),errmsg);
    switch lower(varargin{n})
        case {'name' 'source'}
            varargin{n}=lower(varargin{n});
        otherwise
            error(errmsg);
    end
    assert(ischar(varargin{n+1}),errmsg);
end

result=[];
for k=1:size(LibraryTable,1)
    name=LibraryTable.BookName{k};
    source=LibraryTable.PageName{k};
    match=true;
    for n=1:2:Narg
        switch varargin{n}
            case 'name'
                if any(strfind(name,varargin{n+1}))
                    continue
                else
                    match=false;
                    break
                end
            case 'source'
                if any(strfind(source,varargin{n+1}))
                    continue
                else
                    match=false;
                    break
                end
        end
    end
    if match
        temp.Name=name;
        temp.Source=LibraryTable.PageName{k};
        temp.File=LibraryTable.PageData{k};     
        if isempty(result)
            result=temp;
        else
            result(end+1)=temp;  %#ok<AGROW>
        end
    end
end


end