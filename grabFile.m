% grabFile Make local copy of a specified file
%
% This function makes a local copy of specified file.  Unlike the builtin
% copyfile feature, the absolute location of the file is not required.
% Users can access information adjacent to a feature of interest without
% that file being on the MATLAB path.  For example, a script 'exampleA.m'
% might be stashed inside a folder 'examples' next to a function/class file
% that demonstrates the use of that file.  Users can grab a local copy of
% that script to better understand the function/class without concern that
% the original version has been modified; this is particularly important
% when the function/class is stored in a version control repository.
%
% Generating a local copy depends on two mandatory inputs.
%    grabFile(source,name);
% The input "source" defines absolute file location in one of the following
% ways.
%    -An explicit file or folder name.
%    -The name of a function/classdef file or package folder (also known as
%    a namespace) accessible from the current MATLAB path.
%    -An existing MATLAB variable.
% The input "name" defines the file of interest with respect to the
% location derived from source, with subfolder support and automatic
% forward/backward slash conversion.  For the example described above:
%    grabFile('myPack.myFunc','examples/exampleA.m');
% copies a script from a subfolder next to a function inside a namespace.
%
% If the input "name" indicates a subfolder (without file) or contains a
% wilcard (such as *.m), the matching contents are printed to the
% command window:
%     grabFile(source,'examples');
% or returned as a cell array of character vectors.
%     list=grabFile(source,'examples/*.m');
% The first command shows the full content of the 'examples' subfolder,
% while the second command returns only *.m files in that subfolder.
%
% Source location can be determined automatically within a hyperlink when
% source is set to '-link'.  For example, placing this line:
%     <a href="matlab:grabFile('-link','examples/exampleA.m')">Show example</a>
% inside the initial comment block generates a documentation hyperlink with
% the text "Show example".  Pressing this link opens the file 'exampleA.m'
% within the folder 'examples" located wherever the documented file
% resides.  Note that this hyperlink is only functional with MATLAB's doc
% command and does *not* work with the help command.
%
% Files copied by this function are stored in a subfolder name
% 'grabFile_folder'.  The absolute location of the copied file is returned
% as an output:
%    new=grabfile(source,name);
% when "name" is a specific file, not a folder or wildcard pattern.
% Normally the copied file is automatically opened in the MATLAB editor.
% This behavior is controlled with a third input argument.
%    grabFile(source,name,'show');   % default behavior
%    grabFile(source,name,'noshow'); % copied file not opened
%
% See also copyfile, doc
%
% NOTE: although this function will copy any file on request, it is meant
% for use with text files that the MATLAB editor can understand.  For best
% results, live scripts that will be copied by this function be stored in
% text format (*.m), a feature that was introduced in release 2025a.
% Binary live scripts (*.mlx) are entirely compatible with this function
% but are not fully compatible with version control software such as Git.
%
function varargout=grabFile(source,name,show)

% manage input
Narg=nargin();
assert((Narg >= 2) && ~isempty(source) && ~isempty(name),...
    'ERROR: insufficient input');

if strcmpi(source,'-link') % for use with doc hyperlink
    try
        source=evalin('caller','currentUrl');
    catch
        warning('Hyperlink works through doc but not help');
        return
    end
    source=extractBetween(source,'topic=','&');
    source=source{1};
    while true
        k=strfind(source,'%');
        if isempty(k)
            break
        end
        pattern=source(k(1):k(1)+2);
        actual=char(hex2dec(pattern(2:end)));
        source=strrep(source,pattern,actual);
    end
else
    if isstring(source) || iscellstr(source)
        assert(isscalar(source),...
            'ERROR: cannot grab from multiple sources');
    end
    source=superWhich(source);
    assert(~isempty(source),'ERROR: invalid source');    
end
if isfile(source)
    source=fileparts(source);
end

assert(ischar(name) || isStringScalar(name),'ERROR: invalid name');
k=(name == '/') | (name == '\');
name(k)=filesep();

if (Narg < 3) || isempty(show) || strcmpi(show,'show')
    show=true;
elseif strcmpi(show,'noshow')
    show=false;
else
    error('ERROR: invalid show request');
end

% find target
source=fullfile(source,name);
if isfolder(source) || contains(source,'*')
    try
        data=dir(source);
        assert(~isempty(data));
    catch
        error('ERROR: unable to process source/name combination');
    end
    N=numel(data);
    keep=false(size(data));
    list=cell(1,N);
    for n=1:N
        if data(n).name(1)=='.'
            continue
        elseif data(n).isdir
            list{n}=[data(n).name filesep];
        else
            list{n}=data(n).name;
        end
        keep(n)=true;
    end
    list=list(keep);
    if nargout() == 0
        fprintf('Source content(s):\n');
        fprintf('   %s\n',list{:});
    else
        varargout{1}=list;
    end
    return
else
    assert(isfile(source),'ERROR: requested file not found');
end

% make local copy
local='grabFile_folder';
if ~isfolder(local)
    mkdir(local);
end

[~,file,ext]=fileparts(source);
target=fullfile(local,[file ext]);
copyfile(source,target,'f');

if show
    edit(target);
end

% manage output
if nargout() > 0
    varargout{1}=fullfile(pwd(),target);
end

end

%%
function out=superWhich(in)

out=[];

% function/class name
try %#ok<TRYNC>
    out=which(in);
    assert(~isempty(out));
    if startsWith(out,'built-in')
        out=extractAfter(out,'(');
        out=extractBefore(out,')');
        out=fileparts(out);
    end
    return
end

% variable
if ~ischar(in) && ~isStringScalar(in)
    in=class(in);
    out=superWhich(in);
    return
end

% explicit location
if isfile(in) || isfolder(in)
    out=in;
    return
end

% namespace
z=matlab.metadata.Namespace.fromName(in);
assert(~isempty(z),'ERROR: requested source not found');

buffer=path();
mark=pathsep();
in=strrep(in,'.',[filesep() '+']);
in=['+' in];
while ~isempty(buffer)
    current=extractBefore(buffer,mark);
    if isempty(current)
        current=buffer;
        buffer='';
    else
        buffer=extractAfter(buffer,mark);
    end
    temp=fullfile(current,in);
    if isfolder(temp)
        out=temp;
        break
    end
end

end