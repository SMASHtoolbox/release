% runShell Run commands in an operating system shell
%
% This function passes commands to an operating system shell: 
%    Windows   : DOS
%    Macintosh : bash (typically)
%    Linux    : bash/csh/tcsh (depending on configuration)
% The function can be used on any operating system, but caution
% is needed when moving between between operating systems.  Command
% validity is not tested prior to execution in the shell!
%
% Individual shell commands are specified as a string
%    >> [output,err]=runShell('ls *.m'); % display *.m files in current directory
% If successful, the command's results are stored as a string ("output")
% and the value of "err" is zero; nonzero values of "err" indicate that an
% error was encountered.  By default, command output is also displayed in
% MATLAB's command window.  To suppress this behavior, a second input
% should be passed to the function.
%    >> [...]=runShell(command,'verbose'); % display output [default]
%    >> [...]=runShell(command,'silent'); % suppress output
%
% Multiple shell commands are specified as a cell array of strings.
%    >> runShell({'ls' 'pwd'});
% Command separators, such as semicolons, are generated internally and
% should NOT be specified in the cell array. 
%

%
% created June 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=runShell(command,mode)

% handle input
assert(nargin>0,'ERROR: no shell command(s) given');
if ischar(command)
    command={command};
end
assert(iscell(command),'ERROR: invalid command input');

if (nargin<2) || isempty(mode)
    mode='verbose';
else
    assert(ischar(mode),'ERROR: invalid mode');
end
if mode(1)=='-'
    mode=mode(2:end);
end
switch lower(mode)
    case {'echo','verbose'}
        mode='verbose';
    case {'silent','quiet'}
        mode='silent';
    otherwise
        error('ERROR: invalid mode');
end

% convert commands into an extended string
if ispc
    separator='&';
else
    separator=';';
end

for k=1:numel(command)
    if k==1
        temp=sprintf('%s',command{k});
    else
        temp=sprintf('%s%s %s',temp,separator,command{k});
    end
end

% execute command(s)
if strcmp(mode,'verbose')
    commandwindow;
    [status,output]=system(temp,'-echo');
else
    [status,output]=system(temp);
end

% handle output
if nargout>0
    varargout{1}=output;
    varargout{2}=status;
end

end