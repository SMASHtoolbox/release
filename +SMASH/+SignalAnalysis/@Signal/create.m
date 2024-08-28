function object=create(object,varargin)

object.Name='Signal object';
object.GraphicOptions=SMASH.General.GraphicOptions;
object.GraphicOptions.Marker='none';
object.GraphicOptions.LineStyle='-';

Narg=numel(varargin);
switch Narg
    case 2 % standard mode: Signal(x,y)   
        switch class(varargin{2})
            case 'single'
                object.Precision='single';                
        end
        object.Data=cast(varargin{2}(:),object.Precision);
        numpoints=numel(object.Data);        
        object.Grid=cast(varargin{1}(:),object.Precision);
        if isempty(object.Grid)
            object.Grid=transpose(1:numpoints);
        elseif numel(object.Grid)==1
            object.Grid=repmat(object.Grid,size(object.Data));
            object.Grid(1)=0;
            object.Grid=cumsum(object.Grid);
        end
        assert(numel(object.Grid)==numel(object.Data),...
            'ERROR: incompatible Grid/Data arrays');
    case {3 4} % construct modes: Signal(xd,yd,param) or Signal(xd,yd,param,grid)
       object=construct(object,varargin{:});            
    otherwise
        error('ERROR: invalid number of inputs');
end

object=verifyGrid(object);
if size(object.Data,2)>1
    object.Data=object.Data(:,1);
end

end

function object=construct(object,xd,yd,param,grid)

% manage input
try
    table=[xd(:) yd(:)];
catch
    error('ERROR: inconsistent data arrays');
end
table=sortrows(table,1);
xd=table(:,1);
yd=table(:,2);
Npoints=numel(xd);

if isempty(param)
    param=1;
end
param=ceil(param);
assert(any(param==[1 2]),'ERROR: invalid smoothing order');
switch numel(param)
    case 1
        param(2)=param(1)+1;
    case 2
        assert(param(2)>param(1),'ERROR: invalid smoothing neighborhood');
    otherwise
        error('ERROR: invalid smoothing parameter(s)');
end
order=param(1);
nhood=param(2);
if rem(nhood,2)==0
    nhood=nhood+1;
end

if (nargin<5) || isempty(grid)
    grid=100;
end
if isscalar(grid)
    grid=round(grid);
    grid=linspace(xd(1),xd(end),grid);
end
grid=sort(grid(:));

% perform local smoothing
[y,w]=deal(zeros(size(grid)));
Ln=(nhood-1)/2;
for n=1:Npoints
    left=n-Ln;
    if left < 1
        continue
    end
    right=n+Ln;
    if right > Npoints
        continue
    end
    index=left:right;
    p=polyfit(xd(index),yd(index),order);
    index=(grid>=xd(left)) & (grid<=xd(right));
    y(index)=y(index)+polyval(p,grid(index));
    w(index)=w(index)+1;
 end
y=y./w;

% store results
object.Grid=grid;
object.Data=y;

end