% CODATA Look up physical constants
%
% This function looks up physical constants using CODATA 2018 recommended 
% values.  Quantities matching one or more text patterns are returned as a
% data structure.
%    data=CODATA(pattern1,pattern2,...);
% Patterns are inclusive by default (e.g. 'mass'), but can be made
% exclusive with the addition of an asterisk (e.g. '*electron'). When no
% patterns are specified, "data" contains every tabulated constant. The
% output "data" is a structure fields Quantity, Value, Uncertainty, and
% Unit.
%
% Calling this function with no output:
%    CODATA(pattern1,pattern2,...);
% prints all matching constants in the command window.  Printed values may
% be shown at different precision than the tabulation, so
% numerical calculations should be based on explicit lookup (shown above).
%
% Data obtained from http://physics.nist.gov/constants [E. Tiesinga et al.,
% Rev. Mod. Phys. 93, 025010 (2021).].
%
%
% See also SMASH.Reference
%
function varargout=CODATA(varargin)

persistent data start
if isempty(data)
    location=fileparts(mfilename('fullpath'));
    file=fullfile(location,'data','CODATA.txt');
    fid=fopen(file,'r');
    CU=onCleanup(@() fclose(fid));
    % process header
    previous='';
    while~ feof(fid)
        current=fgetl(fid);
        if isempty(previous) || isempty(current)
            previous=current;
            continue
        elseif all(current == '-')
            break
        end
    end
    start=nan(1,4);
    start(1)=strfind(previous,'Quantity');
    start(2)=strfind(previous,'Value');
    start(3)=strfind(previous,'Uncertainty');
    start(4)=strfind(previous,'Unit');    
    % read data
    entry=struct('Quantity','','Value',[],'Uncertainty',[],'Unit','');
    data=cell(0,4);
    while ~feof(fid)
        buffer=fgetl(fid);
        if isempty(strtrim(buffer))
            continue
        end
        temp=buffer(start(1):start(2)-1);
        entry.Quantity=strtrim(temp);
        temp=buffer(start(2):start(3)-1);
        temp=strrep(temp,' ','');
        temp=strrep(temp,'...','');
        entry.Value=sscanf(temp,'%g',1);
        temp=buffer(start(3):start(4)-1);
        temp=strrep(temp,' ','');
        if strcmpi(temp,'(exact)')
            entry.Uncertainty=nan;
        else
            entry.Uncertainty=sscanf(temp,'%g',1);
        end
        temp=buffer(start(4):end);
        entry.Unit=strtrim(temp);
        if isempty(data)
            data=entry;
        else
            data(end+1)=entry; %#ok<AGROW> 
        end
    end    
end

% manage input
if nargin < 1
    varargin{1}='';
else
    
end

% find matches
keep=false(size(data));
N=numel(varargin);
flag=false(1,N);
for m=1:numel(data)
    flag(:)=false;
    for n=1:N        
        pattern=varargin{n};
        if isempty(pattern) || any(regexpi(data(m).Quantity,pattern))           
            flag(n)=true;
        elseif contains(pattern,'*')
            pattern=strrep(pattern,'*','');
            if ~any(regexpi(data(m).Quantity,pattern))
                flag(n)=true;
            end
        end
        if all(flag)
            keep(m)=true;
        end
    end
end
report=data(keep);

% manage output
if nargout > 0
    varargout{1}=report;
    return
end

L=numel(report);
if L == 0
    fprintf('No matches found\n');
    return
end
temp=SMASH.Text.sprintPlural(L,'quantity','quantities');
fprintf('Found %s:\n\n',temp);
fprintf('%-60s%20s%20s%15s\n','Quantity','Value','Uncertainty','Units');
fprintf(repmat('-',[1 115]));
fprintf('\n')
format='%-60s%20.9g%#20.2g%15s\n';
for k=1:L
    fprintf(format,report(k).Quantity,report(k).Value,...
        report(k).Uncertainty,report(k).Unit);
end
fprintf('\n');

end