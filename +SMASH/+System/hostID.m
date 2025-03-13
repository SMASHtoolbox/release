% hostID Determine computer's host ID 
%
% This function determines the host ID of the computer running MATLAB by
% probing the operating system.  
%    value=hostID;
%
% See also userdir, username
%

% created February 24, 2013 by Daniel Dolan (Sandia National Laboratories)
function value=hostID()

if isunix
    [~,result]=system('hostname -s');
    value=sscanf(result,'%s');
else
    [~,result]=system('ipconfig /all');
    start=regexpi(result,'Host Name');
    result=result(start:end);
    start=regexp(result,':');
    start=start(1)+1;
    value=sscanf(result(start:end),'%s',1);
end

end