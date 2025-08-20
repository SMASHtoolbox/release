% uptime Query system uptime
%
% This function queries how long the current system has been running.
% Total uptime is returned in various units.
%    [S,M,H,D]=uptime(); % seconds, minutes, hours, days
% Note that each output describe the same amount of time, e.g. "S" is sixty
% times larger than "M".
%
% Calling the function without an output.
%    uptime();
% prints the date/time of the last boot up and total time in the command
% window.  The largest unit with a value greater than 1 is automatically
% used; unless the system has recently been rebooted, uptime is usually
% expressed in days.
%
% See also SMASH.System
%
function varargout=uptime()

value=nan(1,4);

% this is undocumented feature has been around for many releases
value(1)=toc(uint64(1));
value(2)=value(1)/60;
value(3)=value(2)/60;
value(4)=value(3)/24;

% manage output
if nargout > 0
    varargout=num2cell(value);
    return
end

label={'seconds' 'minutes' 'hours' 'days'};
for k=numel(value):-1:1
    if value(k) > 1
        fprintf('Local system has been up since %s (%#.4g %s)\n',...
            datestr(now-seconds(value(1))),value(k),label{k});
        return
    end
end

end