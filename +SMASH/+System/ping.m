% ping Send network ping to an IP address
%
% This function sends a network ping to a specified address.
%    delay=ping(address);
% If no address is specified, the ping is sent to the local host machine.
% The output "delay" is the delay time in milliseconds; NaN values
% indicate that the ping was unsuccessful, i.e. the requested address could
% not be reached.  The default time out is 50 ms, but longer time outs can
% be requested for slow connections.
%    delay=ping(address,timeout);
% The input "timeout" is specified in milliseconds.
%
% Calling this method with no output:
%    ping(address);
% prints the ping report in the command window.  The report is also
% returned as a second output.
%    [delay,report]=ping(address);
%
% See also SMASH.System, listIP4, localhost
%

%
% created April 20, 2017 by Daniel Dolan (Sandia National Laboratories
%   
function varargout=ping(address,timeout,mode)

% manage input
if (nargin < 1) || isempty(address)
    address=SMASH.System.localhost();
end
assert(ischar(address) || iscellstr(address),'Invalid address');

if (nargin < 2) || isempty(timeout)
    timeout=50; % ms
end
assert(isnumeric(timeout) && isscalar(timeout) && (timeout > 0),...
    'ERROR: invalid timeout value')

if (nargin < 3) || isempty(mode)
    mode='verbose';
elseif strcmpi(mode,'silent')
    mode='silent';
else
    mode='verbose';
end


% manage multiple IP addresses
if iscellstr(address)
    delay=nan(size(address));
    if strcmp(mode,'verbose')
        fprintf('Testing IP4 : ');
    end
    for n=1:numel(address)
        delay(n)=SMASH.System.ping(address{n},timeout);
        if strcmp(mode,'verbose')
            fprintf('%15s',address{n});
            fprintf(repmat('\b',[1 15]));
        end
    end
    if strcmp(mode,'verbose')
        fprintf('done\n');
    end
    varargout{1}=delay;
    return
end

% generate and use system command
if ispc
    command=sprintf('ping -n 1 -w %g %s',timeout,address);
    %fprintf('%s\n',command);
    %command=sprintf('ping -n 1 -w 2000 %s',address);
else
    command=sprintf('ping -c 1 -W %g %s',timeout,address);
end
[err,result]=system(command);
if err
    delay=nan;
else
    temp=strtrim(result);
    while numel(temp) > 0
        if ispc
            delay=sscanf(temp,'Average = %g',1);
        else    
            delay=sscanf(temp,'time=%g',1);
        end
        if isempty(delay)
            temp=temp(2:end);
            continue
        end
        break
    end
end

% manage output
if nargout == 0
    fprintf('%s',result);
else
    varargout{1}=delay;
    varargout{2}=result;
end

end