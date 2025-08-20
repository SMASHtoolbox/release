% checkCPU Check number of processors
%
% This functions checks the number of *physical* processors on the current
% system.
%    N=checkCPU();
% If no output is requested, the result is printed on the command window.
%
% See also SMASH.System
%

%
% created June 10, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=checkCPU()

% query system based on operating system
switch computer
    case 'PCWIN64'
        [~,b]=system('wmic cpu get NumberOfCores');
        value=sscanf(b(14:end),'%d');
        value=sum(value);       
    case {'MACI64' 'MACA64'}
        [~,b]=system('sysctl hw.physicalcpu');
        value=sscanf(b,'hw.physicalcpu: %d');        
    case 'GLNXA64'
        value=0;
        [~,b]=system('lscpu -p');
        stop=strfind(b,newline());
        start=1;
        for k=1:numel(stop)            
            if b(start) == '#'
                % do nothing
            else
                value=value+1;                                
            end                      
           start=stop(k)+1;
        end
end

% manage output
if nargout == 0
    fprintf('%d CPU(s) detected\n',value);
else
    varargout{1}=value;
end

end