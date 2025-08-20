% username Determine user name
%
% This function returns the name of the current MATLAB user.
%    value=username();
%
% See also hostID, userdir, userpath
%

%
% created May 9, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function value=username()

if isunix % Mac and Linux
    command='whoami';
else % Windows
    command='whoami /upn';
end
[~,value]=system(command);

index=strfind(value,'@');
if ~isempty(index)
    value=value(1:(index(1)-1));
end
value=strtrim(value);

end