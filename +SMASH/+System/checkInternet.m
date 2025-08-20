% checkInternet Determine Internet status
%
% This function returns a logical flag indicating if an Internet connection
% is available.
%    available=checkInternet();
% Requesting a second output:
%    [available,firewall]=checkInternet();
% returns another logical flag indicating if a firewall is present. 
% NOTE: The second test is *considerably* slower than the first!
%
% See also SMASH.System, ping
%

%
% created July 24, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function [available,firewall]=checkInternet(timeout)

% manage input
if nargin < 1
    timeout=[];
end

% look for connection
available=true;
try
    address=java.net.InetAddress.getByName('www.google.com');
catch
    address='';
    available=false;
end

% look for firewall
if nargout >= 2
    if isempty(address)
        firewall=false;
    else
        address=char(address);
        index=strfind(address,'/');
        if numel(index) >= 1
            index=index(end)+1;
        else
            index=1;
        end
        address=address(index:end);
        delay=SMASH.System.ping(address,timeout);
        if isnan(delay)
            firewall=true;
        else
            firewall=false;
        end
    end    
end

end