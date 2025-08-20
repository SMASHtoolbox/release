% renamePattern Batch file rename
%
% This *static* method renames files in the current directory.
%    Collection.renamePattern(in,out);
% Every appearance of the "in" pattern is replaced with the "out" pattern.
% Existing files are *not* overwritten, and a warning is generated when a
% new file would be assigned an existing file name.
%
% NOTE: wildcards (*) are not currently supported.
%
% See also Collection, movefile, pwd
%
function renamePattern(in,out,varargin)

% manage input
assert((nargin >= 2) && ischar(in) && ischar(out),...
    'ERROR: this method requires an input and output character pattern');

%
file=dir(pwd);
count=0;
for n=1:numel(file)
    if ~contains(file(n).name,in)
        continue
    end
    new=strrep(file(n).name,in,out);
    if isfile(new)
        warning('File name "%s" is already in use',file(n).name);
        continue
    end
    movefile(file(n).name,new);
    count=count+1;
end

fprintf('%d files renamed\n',count);

end