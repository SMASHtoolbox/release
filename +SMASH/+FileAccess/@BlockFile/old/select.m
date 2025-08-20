% SELECT Select file for ColumnFile object
%
% This methods selects the file accessed by a ColumnFile object.  The file
% name can be specified directly:
%    >> object=select(object,filename);
% or interactively.
%    >> object=select(object); % user will be prompted to select a file
%
% See also ColumnFile, probe, read, write
%

function object=select(object,name)

if (nargin<2) || isempty(name)
    [filename,pathname]=uigetfile('*.*','Select file');    
    assert(ischar(filename),'ERROR: no file selected');
    name=fullfile(pathname,filename);
end
object.name=name;

end