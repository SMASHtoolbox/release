% userdir Determine user directory
%
% This function returns the home directory of the current user.
%    location=userdir();
%
% See also hostID, username, userpath
%

%
% created July 12, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function location=userdir()

if isunix % Mac and Linux
    location=getenv('HOME');
else % Windows
    location=[getenv('HOMEDRIVE') getenv('HOMEPATH')];
end

end