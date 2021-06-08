% GATHER Combine objects into a SignalGroup
%
% This method combines SignalGroup (and Signal) objects into a new object
% with a common Grid.
%    >> new=gather(object1,object2,...)
%
% See also SignalGroup, split
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=gather(varargin)

temp={};
label={};
xmin =+inf;
xmax=-inf;
dx=inf;
for n=1:nargin
    assert(isa(varargin{n},'SMASH.SignalAnalysis.Signal'),...
        'ERROR: non-gatherable object detected')
    source=varargin{n};
    for m=1:size(source.Data,2)
        temp{end+1}=SMASH.SignalAnalysis.Signal(...
            source.Grid,source.Data(:,m)); %#ok<AGROW>  
        x=temp{end}.Grid;
        xmin=min(xmin,min(x));
        xmax=max(xmax,max(x));
        dx=min(dx,abs(min(diff(x))));        
        switch class(source)
            case 'SMASH.SignalAnalysis.Signal'
                label{end+1}=source.Name; %#ok<AGROW>
            case 'SMASH.SignalAnalysis.SignalGroup'
                label{end+1}=source.Legend{m}; %#ok<AGROW>
        end
    end
end
N=numel(temp);
x=xmin:dx:xmax;
Data=nan(numel(x),N);

for n=1:N
    temp{n}=regrid(temp{n},x); %#ok<AGROW>
    Data(:,n)=temp{n}.Data;
end
object=SMASH.SignalAnalysis.SignalGroup(x,Data);
object.Source='Signal gather';
object.GridLabel=varargin{1}.GridLabel;
object.DataLabel=varargin{1}.DataLabel;
object.Legend=label;

end