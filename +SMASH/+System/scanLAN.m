% scanLAN Scan local area network
%
% This function scans a local area network, returning a list of addresses
% that respond to a ping request.
%    list=scanLAN(); % full range
%    list=scanLAN(pattern); % partial range, e.g. '101-110'
% The output "list" is a cell array of IP addresses.
%
% See also SMASH.System, ping
%

%
% created August 14, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function list=scanLAN(address,timeout)

% manage input
if (nargin < 1) || isempty(address)
    address='*';
else
    assert(ischar(address),'ERROR: invalid address request');
end

if (nargin < 2) || isempty(timeout)
    timeout=50; % milliseconds
else
    assert(isnumeric(timeout) && (timeout > 0),...
        'ERROR: invalid timeout value');
end

% scan for valid IP addresses
list=SMASH.System.listIP4(address);

file=tempname();
file=[file '.bat'];
fid=fopen(file,'w');

for n=1:numel(list)
   fprintf(fid,'ping -4 -n 1 -w %d %s\n',timeout,list{n});
end
fclose(fid);
[~,result]=system(file);

keep=false(size(list));
for n=1:numel(list)
    index=strfind(result,sprintf('Pinging %s',list{n}));
    result=result(index(1):end);
    index=find(result == ':',1,'first');
    result=result(index+1:end);
    temp=sscanf(result,'%c',20);
    if strfind(temp,'Reply from') %#ok<STRIFCND>
        keep(n)=true;           
    end
end
list=list(keep);

end