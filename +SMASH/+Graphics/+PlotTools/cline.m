% cline Draw variable color line
%
% This function draws lines that vary in color from one end to the other.
% Two-dimensional lines are created
%     >> cline(x,y,color);
%     >> cline(x,y,color,name,value,...);
% The third input ("z") must either be a scalar or an array with the same
% number of elements as "x" and "y".  
%
% Three dimensional lines are also suported
%     >> cline(x,y,z,color);
%     >> cline(x,y,z,color,name,value,...);
%
% See also Graphics
%

%
% created January 22, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=cline(x,y,varargin)

% handle input
assert(nargin>=3,'ERROR: insufficient input');
assert(isnumeric(varargin{1}),'ERROR: invalid input');

if (numel(varargin)>1) && isnumeric(varargin{2})
    z=varargin{1};
    level=varargin{2};
    varargin=varargin(3:end);
else
    z=0;
    level=varargin{1};
    varargin=varargin(2:end);
end

% error checking
N=numel(x);
assert(numel(y)==N,'ERROR: incompatible (x,y) data');
x=x(:);
y=y(:);

if numel(z)==1
    z=repmat(z,size(x));
elseif numel(z)==N
    z=z(:);
else
    assert(numel(y)==N,'ERROR: incompatible (x,y,z) data');
end

assert(numel(level)==N,'ERROR: inconsistent # of color levels');

% create patch
x(end+1)=nan;
y(end+1)=nan;
level(end+1)=nan;

h=patch('XData',x,'YData',y,'ZData',z,'CData',level,...
    'FaceColor','none','EdgeColor','interp');
try
    if numel(varargin)>0
        set(h,varargin{:});
    end
catch
    error('ERROR: invalid setting request');
end

% handle output
if nargout>0
    varargout{1}=h;
end


end