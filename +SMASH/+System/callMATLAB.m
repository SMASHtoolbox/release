% callMATLAB Allow MATLAB calls from command shell
%
% This function allows MATLAB commands to be passed from an external
% command shell.  Turning this capability on:
%    callMATLAB('on');
% creates a shell script "callMATLAB.sh" in the current directory.
% Executing that script in an external script passes commands to MATLAB.
%    ./callMATLAB command
% These commands are evaluated in the base workspace, and anything
% displayed in the command window is echoed in the external shell.
%
% Although not always necessary, double quotes should be used around call
% statements to support white space, semicolons, and single quotes.
% Several examples are given below.
%    ./callMATLAB "why" # quotes not required but good practice
%    ./callMATLAB "why; pwd" # quotes required
%    ./callMATLAB "disp('Huh?')" # quotes required
%
% External calls are processed periodically, waiting a fixed time between
% the completion of the last call until starting the next call.  The
% default period is 1 second, but this can be changed with a second input
% argument.
%    callMATLAB('on',period); % period in seconds
% The input "period" can be any number greater than 0 and less than 60.
% Smaller values provide quicker response between the MATLAB and the
% external shell, at the cost of processor overhead.  For best results,
% the period should match the characteristic completion time fort the
% MATLAB calls of interest.
%
% Turning this function off:
%    callMATLAB('off');   
% deletes the shell script from the current directory and disables external
% MATLAB calls.
%
% Calling this function with no input:
%    callMATLAB('off');
% returns a structure indicating the current call state.
%
% See also SMASH.System
%

%
% created September 15, 2019 by Daniel Dolan (Sandia National Laboratories)
%    -TO DO: test multiple sessions and shells
%    -python interface: os.system('./callMATLAB.sh command')
%
function varargout=callMATLAB(state,period)

assert(isunix,'ERROR: this function only works on Unix systems');

%% manage input
location=pwd();
ScriptFile=fullfile(location,'callMATLAB.sh');
subdir=fullfile(location,'.callMATLAB');

if (nargin < 1) || isempty(state)
    temp=dir(subdir);
    if isempty(temp)
        report.State='off';
    else
        report.State='on';
        fid=fopen(fullfile(subdir,'period'),'r');        
        report.Period=fscanf(fid,'%g',1);
        fclose(fid);
    end
    varargout{1}=report;
    return
else
    assert(ischar(state),'ERROR: invalid state');
end

if (nargin < 2) || isempty(period)
    period=1;
else
    assert(isnumeric(period) && isscalar(period) && (period > 0) && (period < 60),...
        'ERROR: invalid period');
end

%% timer setup
persistent InputPipe OutputPipe

monitor=timerfindall('Name','callMATLAB','Tag',location);
if isempty(monitor)
    monitor=timer('Name','callMATLAB','Tag',location,...
        'BusyMode','drop','ExecutionMode','fixedSpacing',...
        'TimerFcn',@readPipe,'StopFcn',@dirCleanup,...
        'Period',period);
elseif strcmpi(monitor.Running,'on')
    stop(monitor);    
end
monitor.Period=period;
    function readPipe(varargin)
        local=fullfile(location,'.callMATLAB','ready');
        if exist(local,'file')
            delete(local);
        else
            return        
        end        
        command=sprintf('cat "%s"',fullfile(subdir,'InputPipe'));
        [~,temp]=system(command);
        temp=strtrim(temp);
        disp(['>> ' temp]);
        temp=strrep(temp,'''','''''');       
        try
            T=sprintf('evalc(''%s'')',temp);
            T=evalin('base',T);
        catch ME
            sprintf('%s\n',ME.message);
        end        
        disp(T);
        command=sprintf('echo "%s" > "%s" &',T,fullfile(subdir,'OutputPipe'));  
        system(command);
        command=sprintf('touch "%s"',fullfile(subdir,'done'));
        system(command);
    end
    function dirCleanup(varargin)
        if exist(subdir,'dir')
            command=sprintf('rm -r "%s"',subdir);
            system(command);
        end
        if exist(ScriptFile,'file')
            delete(ScriptFile)
        end
    end

%% process input
switch state
    case 'on'       
        if exist(subdir,'dir')           
            [~,~]=system(sprintf('rm -r "%s"',subdir));   
        end
        mkdir(subdir);
        command=sprintf('echo "%.2f" > "%s"',period,fullfile(subdir,'period'));
        system(command);
        InputPipe=fullfile(subdir,'InputPipe');
        system(['mkfifo "' InputPipe '"']);
        OutputPipe=fullfile(subdir,'OutputPipe');
        system(['mkfifo "' OutputPipe '"']);
        fid=fopen(ScriptFile,'w');
        fprintf(fid,'#!/bin/bash\n');
        %fprintf(fid,'echo "$1" > "%s" &\n',fullfile(subdir,'InputPipe'));
        fprintf(fid,'echo "$@" > "%s" &\n',fullfile(subdir,'InputPipe'));
        fprintf(fid,'touch "%s"\n',fullfile(subdir,'ready'));
        fprintf(fid,'while true; do\n');
        local=fullfile(subdir,'done');
        fprintf(fid,'\t if test -f "%s"; then\n',local);
        fprintf(fid,'\t\t rm "%s"\n',local);
        fprintf(fid,'\t\t cat "%s"\n',fullfile(subdir,'OutputPipe'));
        fprintf(fid,'\t\t break\n');
        fprintf(fid,'\t else\n');
        fprintf(fid,'\t\t sleep 0.2\n');
        fprintf(fid,'\t fi\n');
        fprintf(fid,'done\n');
        fclose(fid);
        fileattrib(ScriptFile,'+x','u');
        if strcmpi(monitor.Running,'off')
            start(monitor)
        end
    case 'off'        
        % nothing to do
end

end