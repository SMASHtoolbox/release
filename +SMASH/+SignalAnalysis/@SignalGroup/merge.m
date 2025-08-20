% MERGE Merge objects into a single object
%
% This method merges multiple SignalGroup objects (each containing the same
% number of signals) into a single object.
%    >> new=merge(object1,object2,...);
% The new object Grid is determined by the outermost points of the source
% object, spaced by the smallest source grid spacing.  Source objects are
% added to this new grid sequentially, causing overlapping information to
% appear as summation.  Points that do not correspond to any source
% object are assigned to NaN.
%
% Merged objects inherit most of their properties from the first source
% object, though Grid, Data, and LimitIndex are obviously changed in the
% process.  The object Source is updated to reflect this change and the
% ObjectHistory is reset.
%
% See also SignalGroup
%

%
% created November 24, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=merge(varargin)

% handle input
assert(nargin>1,'ERROR: at least two objects needed')

% merge inputs
object=varargin{1};
numsignals=object.NumberSignals;  
for n=2:nargin  
    % error checking
    assert(isa(varargin{n},'SMASH.SignalAnalysis.SignalGroup'),...
        'ERROR: non-Signal input detected')
    assert(varargin{n}.NumberSignals==numsignals,...
        'ERROR: incompatible number of signals detected');    
    % pairwise merge     
    for m=1:numsignals
        A=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,m));
        B=SMASH.SignalAnalysis.Signal(varargin{n}.Grid,varargin{n}.Data(:,m));
        temp=merge(A,B);
        if m==1
            Grid=temp.Grid;
            Data=nan(size(temp.Data,1),numsignals);           
        end
        Data(:,m)=temp.Data;
    end
    object.Grid=Grid;
    object.Data=Data;
end
object.LimitIndex='all';
object.Source='Object merge';
%object=concealProperty(object,'SourceFormat','SourceRecord');
object.ObjectHistory={}; % start fresh

end