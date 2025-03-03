% checkMemory Check memory use
%
% This function checks the memory used by MATLAB.
%    report=checkMemory();
%    checkMemory();
% The first command returns memory information in a structure, while the
% second command prints this information in the command window.
%
% Memory used by the current MATLAB process is expressed in gigabytes by
% default.  An optional input may be used to indicate kilobytes ('kB'),
% megabytes ('MB'), gigabytes ('GB'), or terabytes ('TB').
%    checkmemory('MB');
%    report=checkMemory('kB');
%
% NOTE: memory values and percentages returned by this function
% are estimates!  Actual results may with operating system, computer
% hardware, and system load.  Unlike MATLAB's memory function, this
% function is available on all operating systems.
%
% See also SMASH.System, memory
%

%
% created June 4, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=checkMemory(units)

% manage input
if (nargin < 1) || isempty(units)
    units='GB';    
else
    errmsg='ERROR: invalid units';
    assert(ischar(units),errmsg);
    switch lower(units)
        case 'kb'
            units='kB';
        case 'mb'
            units='MB';
        case 'gb'
            units='GB';
        case 'tb'
            units='TB';
        otherwise
            error(errmsg);
    end
end
    function out=scaleNumber(in)
        switch units
            case 'kB'
                out=in;
            case 'MB'
                out=in/1024;
            case 'GB'
                out=in/1024^2;
            case 'TB'      
                out=in/1024^3;
        end
    end

persistent pid

report.Units=units;
if isunix
    % find process ID
    if isempty(pid)       
        target=matlabroot();
        temp=readCommand('ps -o ppid');
        for k=1:numel(temp)
            pid=temp{k};
            name=readCommand(['ps -p ' pid ' -o command']);
            if any(regexp(name{1},target))
                break
            end
        end        
    end 
    temp=readCommand('ps -p %s -o rss',pid);
    temp=sscanf(temp{1},'%g',1);    
    report.MATLAB=scaleNumber(temp);
    temp=readCommand('ps -p %s -o %%mem',pid);
    report.Percentage=sscanf(temp{1},'%g',1);
else % deal with Windows
   [user,sys]=memory();
    report.MATLAB=scaleNumber(user.MemUsedMATLAB/1024);
    report.Percentage=user.MemUsedMATLAB/sys.PhysicalMemory.Total*100;
end

% manage output
if nargout == 0
    fprintf('MATLAB is using %#.2g %s of memory ',report.MATLAB,report.Units);
    fprintf('(%#.2g%% of system total)\n',report.Percentage);
else
    varargout{1}=report;
end

end

function out=readCommand(varargin)

command=sprintf(varargin{:});
[~,list]=system(command);

out={};
while ~isempty(list)
    [value,~,~,next]=sscanf(list,'%s',1);
    if ~isempty(value)
        out{end+1}=value; %#ok<AGROW>
    end
    list=list(next:end);
end

out=out(2:end);

end