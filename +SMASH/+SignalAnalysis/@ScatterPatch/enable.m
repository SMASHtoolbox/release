% enable Enable patches
% 
% This method enables patches for plotting/processing. The default call:
%    enable(object);
% enable all patches.  
%
% Specific enable criterea are specified by name/value pairs.
%    enable(object,name,value,...);
% Valid names include:
%    -'Horizontal', which specifies a *mapped* horizontal range [umin umax].
%    -'Vertical', which specifies a *mapped* vertical range [vmin vmax].
%    -'Quality', which specifies a quality range [Qmin Qmax].
%    -'Group', which indicates group number.  Values must be consistent
%    with the GroupList property.
% Infinite values can be used as range placeholders, e.g. a 'Horizontal'
% specification of [0 +inf] enables all grid values >= 0.  Criteria can be
% stacked in any order, but patches are only enabled when *all* conditions
% within a method call are satisfied.
%
% See also ScatterPatch, disable, plot, process
%
function enable(object,varargin)

% manage object arrays
N=numel(object);
if N > 1
    for n=1:N
        enable(object(n),varargin{:});
    end
    return
end

% make all points active (default state)
rows=size(object.RawData,1);
if nargin == 1
    object.RawData(:,6)=true(rows,1);
    return
end

% manage options
option=struct('Horizontal',[],'Vertical',[],'Quality',[],'Group',[]);
try
    option=SMASH.Developer.options2struct(option,varargin{:});
catch ME
    throwAsCaller(ME);
end

if isempty(option.Horizontal)
    option.Horizontal=[-inf +inf];
else
    bound=option.Horizontal;
    assert(isnumeric(bound) && (numel(bound) == 2),...
        'ERROR: invalid time bound');
    option.Horizontal=sort(bound);
end
if isempty(option.Vertical)
    option.Vertical=[-inf +inf];
else
    bound=option.Vertical;
    assert(isnumeric(bound) && (numel(bound) == 2),...
        'ERROR: invalid frequency bound');
    option.Vertical=sort(bound);
end
if isempty(option.Quality)
    option.Quality=[0 +inf];
else
    bound=option.Quality;
    assert(isnumeric(bound) && (numel(bound) == 2),...
        'ERROR: invalid quality bound');
    option.Quality=sort(bound);
end
if isempty(option.Group)
    option.Group=object.GroupList;
else
    ERRMSG='ERROR: invalid group number(s)';
    assert(isnumeric(option.Group),ERRMSG);
    for n=1:Numel(option.Group)
        assert(any(option.Group(n) == option.Group),ERRMSG);
    end
end

% enable points
data=object.MappedData;
index=false(rows,4);
u=data(:,1);
v=data(:,2);
area=data(:,3).*data(:,4);
Q=10*log10(max(area)./area);
index(:,1)=(u >= option.Horizontal(1)) & (u <= option.Horizontal(2));
index(:,2)=(v >= option.Vertical(1)) & (v <= option.Vertical(2));
index(:,3)=(Q >= option.Quality(1)) & (Q <= option.Quality(2));
index(:,4)=any(data(:,5) == option.Group,2);
data(all(index,2),6)=true;
object.RawData=data;

end