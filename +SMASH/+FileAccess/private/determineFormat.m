% determineFormat Determine file format
%
% This function determines the format of a file as automatically as
% possible.  The file's extension is used if there is an clear match
% to a supported format.  Format matching can be restricted to a subset of
% supported formats to minimize ambiguity.  If a clear match is not
% possible, the user is prompted to select a format consistent with the
% file's extension.
%
% To compare a specific file against all supported formats:
%    >> format=determineFormat(filename);
% Passing a second input:
%    >> format=determineFormat(filename,valid);
% restricts matching to the formats named in the cell array "valid".
%
% Omiting the file name:
%   >> format=determineFormat; % full matching
%   >> format=determineFormat('',valid); % restricted matching
%   >> format=determineFormat('',valid,'Pick a file'); % customize prompt title
% prompts the user to select a file.  The complete file name, including
% path, is returned as the second output.
%   >> [format,file]=determineFormat(...);
%
% See also FileAccess
%

%
% created October 29, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function [format,FileName]=...
    determineFormat(FileName,ValidFormats,DialogTitle)

% supported formats
format={};

format{end+1}='block';
format{end+1}='column';
format{end+1}='oceanoptics';
format{end+1}='optronicslab';
format{end+1}='optronicslabdump';
format{end+1}='tag';

format{end+1}='acqiris';
format{end+1}='agilent';
format{end+1}='keysight';
format{end+1}='lecroy';
format{end+1}='tektronix';
format{end+1}='yokogawa';
format{end+1}='zdas';
format{end+1}='saturn';

format{end+1}='film';
format{end+1}='graphics';
format{end+1}='optronis';
format{end+1}='hamamatsu';
format{end+1}='kentech';
format{end+1}='plate';
format{end+1}='sbfp';
format{end+1}='sydor';
format{end+1}='winspec';

format{end+1}='dig';
format{end+1}='pff';
format{end+1}='sda';

%format{end+1}='thriftysignal';
format{end+1}='taf';

%fprintf('There are %d supported formats\n',numel(format));

% handle input
if nargin<1
    FileName='';
end

if (nargin<2) || isempty(ValidFormats)
    ValidFormats=format;
elseif ischar(ValidFormats)
    ValidFormats={ValidFormats};
end
assert(iscell(ValidFormats),'ERROR: invalid format ValidFormats');
ValidFormats=lower(ValidFormats);
ValidFormats=unique(ValidFormats);
ValidFormats=transpose(ValidFormats(:));

if (nargin<3) || isempty(DialogTitle)
    DialogTitle='Select file';
end

% manage format shortcuts
match=cellfun(@(x) strcmp('digitizer',x),ValidFormats);
match=find(match);
if logical(match)
    insert={'agilent' 'lecroy' 'tektronix' 'yokogawa' 'zdas' 'saturn'};
    ValidFormats=[ValidFormats(1:match-1) insert ValidFormats(match+1:end)];
end

match=cellfun(@(x) strcmp('imaging',x),ValidFormats);
match=find(match);
if logical(match)
    insert={'film' 'graphics' 'optronis' 'hamamatsu' 'kentech' 'plate' 'sbfp' 'winspec'};
    ValidFormats=[ValidFormats(1:match-1) insert ValidFormats(match+1:end)];
end

% verify ValidFormats
NValidFormats=numel(ValidFormats);
for m=1:NValidFormats
    match=cellfun(@(x) strcmp(ValidFormats{m},x),format);
    assert(any(match),'ERROR: invalid format requested');
end

% file management
if isempty(FileName)
    [FileName,PathName]=uigetfile({'*.*','All files'},DialogTitle);
    assert(ischar(FileName),'ERROR: no file selected');   
    FileName=fullfile(PathName,FileName);
end
%assert(exist(FileName,'file')==2,'ERROR: file not found');

[PathName,BaseName,extension]=fileparts(FileName);
if isempty(PathName)
    PathName=pwd;
end
FileName=fullfile(PathName,[BaseName extension]);

% determine file format
switch lower(extension)
    case '.bin'
        choice={'agilent'};
    case '.bmp'
        choice={'graphics'};
    case '.dig'
        choice={'dig'};
    case '.gif'
        choice={'graphics'};
    case '.h5'
        choice={'acqiris' 'agilent' 'film' 'keysight'};
    case '.hdf'
        choice={'kentech' 'film' 'saturn' 'sydor' 'zdas'};
    case '.hdr'
        choice={'film'};
        fileimg=fullfile(PathName,[BaseName '.img']);
        fileIMG=fullfile(PathName,[BaseName '.IMG']);
        filehdf=fullfile(PathName,[BaseName '.hdf']);
        fileHDF=fullfile(PathName,[BaseName '.HDF']);
        if exist(fileimg,'file')
            FileName=fullfile(PathName,[BaseName '.img']);
        elseif exist(fileIMG,'file')
            FileName=fullfile(PathName,[BaseName '.IMG']);
        elseif exist(filehdf,'file')
            FileName=fullfile(PathName,[BaseName '.hdf']);
        elseif exist(fileHDF,'file')
            FileName=fullfile(PathName,[BaseName '.HDF']);
        else
            error('ERROR: no associated *.img or *.hdf file');
        end
    case '.imd'
        choice={'optronis'};
    case '.img'
        headerhdr=fullfile(PathName,[BaseName '.hdr']);
        headerHDR=fullfile(PathName,[BaseName '.HDR']);
        headerinf=fullfile(PathName,[BaseName '.inf']);
        headerINF=fullfile(PathName,[BaseName '.INF']);
        if exist(headerhdr,'file')||exist(headerHDR,'file')
            choice={'film'};
        elseif exist(headerinf,'file')||exist(headerINF,'file')
            choice={'plate'};
        else
            choice={'hamamatsu','sbfp'};
        end
    case '.imi'
        choice={'optronis'};
        fileimd=fullfile(PathName,[BaseName '.imd']);
        fileIMD=fullfile(PathName,[BaseName '.IMD']);
        if exist(fileimd,'file')
            FileName=fileimd;
        elseif exist(fileIMD,'file')
            FileName=fileIMD;
        else
            error('ERROR: no associated *.imd file');
        end
    case '.inf'
        choice={'plate'};
        fileimg=fullfile(PathName,[BaseName '.img']);
        fileIMG=fullfile(PathName,[BaseName '.IMG']);
        if exist(fileimg,'file')
            FileName=fileimg;
        elseif exist(fileIMG,'file')
            FileName=fileIMG;
        else
            error('ERROR: no associated *.img file');
        end
    case '.isf'
        choice={'tektronix'};
    case {'.jpg','.jpeg'}
        choice={'graphics'};
    case '.pff'
        choice={'pff'};
    case '.png'
        choice={'graphics'};
    case '.spe'
        choice={'winspec'};
    case '.sda'
        choice={'sda'};
    case '.taf'
        choice={'taf'};
    case {'.tif','.tiff'}
        choice={'graphics'};
    case '.trc'
        choice={'lecroy'};
    %case '.tsi'
    %    choice={'thriftysignal'};
    case '.wfm'
        choice={'tektronix' 'yokogawa'};
    otherwise
        choice={'block' 'column' 'oceanoptics' 'optronicslab' 'optronicslabdump' 'tag'};
end

Nchoice=numel(choice);
keep=false(1,Nchoice);
for m=1:Nchoice
    match=cellfun(@(x) strcmp(choice{m},x),ValidFormats);
    if any(match)
        keep(m)=true;
    end
end
choice=choice(keep);

Nmatch=numel(choice);
if Nmatch==1
    format=choice{1};
elseif Nmatch>1
    dlg=SMASH.MUI.Dialog;
    dlg.Hidden=true;
    dlg.Name='Select format';
    entry=sprintf('Extension "%s" is ambiguous',extension);
    addblock(dlg,'text',entry);
    choice{end+1}=' ';
    hlist=addblock(dlg,'listbox','Select the file format:',choice);
    set(hlist(end),'String',choice(1:end-1),'Callback',@makeChoice);
    button=addblock(dlg,'button',{'Done','Cancel'});
    set(button(1),'Callback',@makeChoice);
    set(button(2),'Callback','delete(gcbf)');
    locate(dlg,'center');
    dlg.Hidden=false;
    previous=SMASH.Graphics.FigureTools.focus();
    if ~isempty(previous)
        CU=onCleanup(@() SMASH.Graphics.FigureTools.focus(previous));
    end
    SMASH.Graphics.FigureTools.focus(dlg.Handle);
    waitfor(button(1));
    try
        result=probe(dlg);
        delete(dlg);
    catch
        error('ERROR: unable to resolve format ambiguity');
    end
    format=result{1};
else
    error('ERROR: file does not match expected format(s)');
end

    function makeChoice(varargin)
        style=get(gcbo,'Style');
        if strcmpi(style,'pushbutton')
            % keep going
        elseif strcmpi(style,'listbox') && strcmpi(get(gcbf,'SelectionType'),'open')
            % keep going
        else
            return
        end        
        delete(button(1));
    end

end