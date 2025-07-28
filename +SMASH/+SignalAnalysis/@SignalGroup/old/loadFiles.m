% UNDER CONSTRUCTION
% loadFiles Load data from multiple files
%
% This method creates a SignalGroup object by loading data from multiple
% files.
%    object=loadFiles(pattern); % determine format from file extension
%    object=loadFiles(pattern,format); % manually specify format.
% The input "pattern" is a file name pattern, such as '*.txt'.  The input
% "format" is optional when the file extension is unique; users are
% prompted to resolve format ambiguity (as needed) unless the format is
% specified.  
%
% See also SignalGroup
%

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=loadFiles(pattern,format)

% manage input
assert(nargin >= 1,'ERROR: insufficient input');

assert(ischar(pattern),'ERROR: invalid file name pattern');

if (nargin < 2) || isempty(format)
    format=SMASH.FileAccess.determineFormat(pattern);    
else
    assert(ischar(format),'ERROR: invalid format');
    format=lower(format);
end

% load files
list=dir(pattern);
object=[];
label={};
for m=1:numel(list)
    switch format
        case {'agilent' 'keysight'}
            report=SMASH.FileAccess.probeFile(list(m).name,format);
            temp=cell(1,report.NumberSignals);
            for n=1:report.NumberSignals
                temp{n}=SMASH.SignalAnalysis.Signal(list(m).name,format,n);
                label{end+1}=sprintf('%s, Record %d',list(m).name,n); %#ok<AGROW>
            end
        otherwise
            temp=SMASH.SignalAnalysis.Signal(list(m).name,format);                        
            temp={temp};
            label{end+1}=list(m).name; %#ok<AGROW>
    end
    if isempty(object)
        object=SMASH.SignalAnalysis.SignalGroup(temp{:});
    else
        object=gather(object,temp{:});
    end
end

object.Legend=label;

end