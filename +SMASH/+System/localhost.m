% localhost Determine local IP address
%
% This function determines the local IP address, regardless of the current
% operating system.
%    address=localhost();
%
% See also System, listIP4, ping
%

%
% created April 26, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function address=localhost()

if ispc
    [~,result]=system('ipconfig /all');
    start=strfind(result,'IPv4 Address');
    assert(~isempty(start),'ERROR: no IP4 network found');
    result=result(start:end);
    while ~isempty(result)
        [temp,~,~,next]=sscanf(result,'%s',1);
        value=sscanf(temp,'%d.%d.%d.%d',4);
        if numel(value) ~= 4
            result=result(next:end);
        else
            break
        end
    end    
    address=sprintf('%d.%d.%d.%d',value);
    %[~,result]=system('ping -n 1 localhost');
    %result=sscanf(result,'%*s %s',1);
    %command=sprintf('ping -n 1 %s',strtrim(result));
    %[~,result]=system(command);
    %result=sscanf(result,'%*s %*s %s',1);
    %address=result(2:end-1);
else
    [~,result]=system('bash -c ''hostname''');
    command=sprintf('bash -c ''ping -c 1 %s'' ',strtrim(result));
    [~,result]=system(command);
    result=sscanf(result,'%*s %*s %s',1);
    address=result(2:end-2);
end

end