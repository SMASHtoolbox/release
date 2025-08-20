% shutdownWindows Send Windows shutdown command
%
% This function sends a Windows shutdown command to an IP address.
%    shutdownWindows(password,address);
% The first argument "password" must be the Administrator password for the
% machine at the specified "address" (e.g., '192.168.85.1').  Multiple
% addresses can be specified:
%    shutdownWindows(password,address1,address2,...);
% for machines with a common Administrator password.
%
% NOTE: passwords are transmitted without encryption, so this function
% should only be used on a closed network.  The host machine and all
% clients must be properly configured *outside* of MATLAB for remote
% shutdown.
%
% See also SMASH.System
%

%
% created October 23, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function shutdownWindows(password,varargin)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');
assert(ischar(password),'ERROR: invalid password');

[~,list]=system('net use');

% send shutdown command(s)
for m=1:numel(varargin)
    % verify address
    address=varargin{m};
    try
        address=packtools.call('listIP4',address);
    catch
        error('ERROR: invalid IP address');
    end
    for n=1:numel(address)
        delay=packtools.call('ping',address{n},100);
         if isnan(delay)
             fprintf('No response from %s\n',address{n});
             continue
         end
         % verify network use
         if ~contains(list,address{n})
             command=sprintf('net use \\\\%s /user:Administrator %s',...
                 address{n},password);
             [value,response]=system(command);
             if value > 0
                 disp(response);
                 continue
             end
             pause(1);
         end
         % send command
         command=sprintf('shutdown -s -m \\\\%s',address{n});
         [value,response]=system(command);
         if value > 0
             disp(response);
         end         
    end        
end

end