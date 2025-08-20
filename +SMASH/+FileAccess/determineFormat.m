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
% NOTE: this function points to private function in the FileAccess package.
%

function varargout=determineFormat(varargin)

if nargout==0
    format=determineFormat(varargin{:});
    fprintf('The determined format is ''%s''\n',format);
else
    varargout=cell(1,nargout);
    [varargout{:}]=determineFormat(varargin{:});
end

end