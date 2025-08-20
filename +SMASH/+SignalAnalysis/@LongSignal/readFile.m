% readFile Read data file
%
% This method reads the data file assocated with a LongSignal object.
%   result=readFile(object,[start stop]); % read finite grid range
%   result=readFile(object,[-inf stop]); % read starts at first grid point
%   result=readFile(object,[start +inf]); % read stops at last grid point
%   result=readFile(object,[-inf +inf]); % read entire grid range
% The second input indicates the grid range to be read.  If no range is
% specified, the user is asked to confirm a complete file read.
%
% See also LongSignal
%

% quick access mode (bypass erorr checking)
%    result=readFile(object,index,'quick');
% 

%
% created May 25, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function result=readFile(object,range,mode)

t=[object.Start object.Stop];
dt=object.Increment;

% manage input
if (nargin == 3) && strcmpi(mode,'quick')
    index=range;
else
    if nargin < 2
        commandwindow();
        fprintf('Reading the entire data file may take a while\n');
        choice=input('Type "yes" to continue: ','s');
        if ~strcmp(choice,'yes')
            result=[];
            return
        end
        range=[-inf +inf];
    else
        assert(isnumeric(range) && (numel(range) == 2) && (diff(range) >0),...
            'ERROR: invalid grid range');
    end
    index=nan(1,2);    
    if range(1) <= t(1)
        index(1)=1;
    else
        index(1)=ceil((range(1)-t(1))/dt);
    end    
    if range(2) >= t(2)
        index(2)=object.NumberPoints;
    else
        index(2)=floor((range(2)-t(1))/dt);
    end
    assert(index(2) >= index(1),'ERROR: specified range contains no data');
end

% read index
count=index(2)-index(1)+1;
data=h5read(object.File,'/Signal',[index(1) 1],[count object.NumberSignals]);

time=index(1):index(2);
time=t(1)+(time-1)*dt;
persistent dummy
if isempty(dummy) || (size(data,2) ~= object.NumberSignals)
    dummy=SMASH.SignalAnalysis.SignalGroup(time,data);    
end
result=reset(dummy,time,data);

end