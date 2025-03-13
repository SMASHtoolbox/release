% bash Bash shell mode
%
% This function starts Bash shell mode, where all input typed into the
% MATLAB command window is passed directly to Unix.
%    bash();
% Bash mode persists until the user types "stop" on an otherwise empty line.
%
% Shell processes with interactive control may not properly with this
% function.  For example, the "less" % command uses page control that is
% incompatible with the MATLAB command window.  Alternatives using "cat"
% are acceptable.
%    cat filename # display file
%    man ps | cat # direct manual text to cat
% For the same reasons, the "ps" command should be used in place of "top".
%
% If a process appears to hang, it may be that an interactive feature has
% masked MATLAB's key bindings.  It is *usually* possible to kill these
% processes by pressing control-backslash (^-\).  Note that some programs,
% particularly text editors, will only terminate with very specific key
% combinations!
%
% See also SMASH.System
%

%
% created September 16, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function bash()

assert(isunix(),'ERROR: this command only works on Unix systems');


transition='%% end user commands %%';
Ntransition=numel(transition);

prompt=sprintf('%s@%s$ ',SMASH.System.username,SMASH.System.hostID);

[~,declare]=system('export');
disp('Entering bash shell');
disp('Type "stop" to return to MATLAB');
while true
    
    in=strtrim(input(prompt,'s'));
    if strcmp(in,'stop')
        disp('Exiting bash shell');
        break
    elseif isempty(in)
        continue
    end
    command={};
    command{end+1}=sprintf('%s',declare); %#ok<*AGROW>
    command{end+1}=in;
    command{end+1}=sprintf('echo %s',transition);
    command{end+1}='export';   
    [~,out]=system(sprintf('%s \n',command{:}));
    index=strfind(out,transition);
    disp(out(1:(index-1)));    
    declare=out(index+Ntransition:end);    
end

end
