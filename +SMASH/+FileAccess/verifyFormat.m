% verifyFormat Verify file format
%
% This function determines if a requested format name is supported by the
% FileAccess package.
%    verifyFormat(name); % result printed in the command window
%    valid=verifyFormat(name); % logical result returned
% The input "name" must be a character array.
%
% See also SMASH.FileAccess, SupporteFormats
%

%
% created February 10, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=verifyFormat(name)

% manage input
assert(nargin > 0,'ERROR: no format specified');
assert(ischar(name),'ERROR: invalid format name');

% sweep through supported formats
list=packtools.call('SupportedFormats');
match=false;
for k=1:numel(list)
    if strcmpi(name,list{k})
        match=true;
        break
    end
end

% manage output
if nargout == 0
    if match
        fprintf('''%s'' is a valid file format\n',name);
    else
        fprintf('''%s'' is *not* a valid file format\n',name);
    end
else
    varargout{1}=match;
end

end