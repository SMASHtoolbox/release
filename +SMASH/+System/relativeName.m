% relativeName Generate relative file name
%
% This function generates a relative name for a source file with respect to
% a reference folder.
%    name=relativeName(source,reference);
% Mandatory input "source" indicates the absolute file name, while optional
% input "reference" indicates the folder the relative name will be based
% on; the current folder is used if this input is empty or omitted.  Both
% inputs must be character arrays or scalar strings.
%
% The output "name" is a character array describing the file relative to
% the reference folder.  Single or double dots, along with file separator
% slashes, are shown to the left of the base file name.
%
% See also SMASH.System
%
function name=relativeName(source,reference)

% manage input
assert(nargin >= 1,'ERROR: insufficient input');
source=SMASH.Text.text2char(source,'ERROR: invalid source');
[location,~,~]=fileparts(source);
if isempty(location)
    source=fullfile(pwd,source);
end

if (nargin < 2) || isempty(reference)
    reference=pwd();
else
    reference=SMASH.Text.text2char(reference,'ERROR: invalid reference');
    assert(isfolder(reference),'ERROR: invalid reference folder')
end

if contains(source,reference)
    name=strrep(source,reference,'.');
    return
end

prefix='';
while ~isempty(reference)
    reference=fileparts(reference);
    prefix=fullfile(prefix,'..');
    if contains(source,reference)
        source=strrep(source,reference,'');
        name=fullfile(prefix,source);
        return
    end
end

error('ERROR: unable to generate relative name');

end