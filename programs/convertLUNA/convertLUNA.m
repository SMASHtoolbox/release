% convertLUNA Conversion tool for LUNA fiber scan files
%
% This program converts files generated by a LUNA optical backscatter
% reflectometer to compact format.  To launch the program, type:
%     >> convertLUNA
% in the command window.  A dialog box will be created to allow interactive
% selection of the source directory, modifications, and target file.  All
% *.obr files in the source directory will be inserted as LUNA objects in a
% Sandia Data Archive (SDA) file.  Each object is labeled with the base
% file name (extension removed).
%
% The graphical interface can be bypassed by passing inputs to the program
% directly.
%     >> convertLUNA(source,target,step,range);
% The input "source" is mandatory.
%     -Passing a source directory convertes all *.obr files in that
%     directory (as in interactive mode).
%     -Specific files can be converted by passing a cell array of file
%     names.  Binary (*.obr) and text files generated by a LUNA can be
%     specified.
% The input "target" is also mandatory: it should be a file name with the
% extension *.sda.  Inputs "step" and "range" are optional.  The input
% "step" can be a scalar (applied to all files) or a cell array of scalars
% (specific step values for each file); empty values indicate no
% modification..  The input "range" can be a two-element array [tmin tmax]
% (all files) or a cell array of values (two-element or empty) specific to
% each file.
%
% See also SMASH.FileAccess.LUNA
%

%
% created May 1, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=convertLUNA(source,target,step,range)

if isdeployed
    varargout{1}=1;
end

% manage input
if nargin==0 % interactive mode
    convertLUNA_GUI;
    return
end

if isdir(source)
    pathname=source;
    filename=dir(fullfile(pathname,'*.obr'));
    N=numel(filename);
    source=cell(1,N);
    for n=1:N
        source{n}=fullfile(pathname,filename(n).name);
    end
elseif ischar(source)
    source={source};
end
assert(iscellstr(source),'ERROR: invalid source input');

if (nargin<2) || isempty(target)
    error('ERROR: no target file specified');
end
[~,~,extension]=fileparts(target);
assert(strcmpi(extension,'.sda'),...
    'ERROR: target file extension must be *.sda');
if exist(target,'file')
    warning('Existing target file being overwritten');
    delete(target);
end

if nargin<3
    step=[];
end
if isnumeric(step)
    step=repmat({step},size(source));
end

if nargin<4
    range=[];
end
if isnumeric(range)
    range=repmat({range},size(source));
end

% perform conversion
hw=waitbar(0,'Converting LUNA scan');
N=numel(source);
for n=1:N
    message=sprintf('Converting LUNA scan %d of %d',n,N);
    waitbar(n/N,hw,message);
    [~,shortname,extension]=fileparts(source{n});
    filename=[shortname extension];
    try
        object=SMASH.FileAccess.LUNA(source{n});
    catch    
        warning('"%s" is not a valid LUNA file',filename);
        continue
    end    
    if isempty(step{n}) && isempty(range{n})
        % do nothing
    else
        object=modify(object,step{n},range{n});
    end
    store(object,target,shortname,'Converted LUNA scan');    
end
delete(hw);

end
