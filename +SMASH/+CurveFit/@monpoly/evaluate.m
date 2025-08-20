% UNDER CONSTRUCTION
function varargout=evaluate(object,x)

x0=object.Reference(1);

% manage input
assert(nargin == 2,'ERROR: invalid number of inputs');
if (nargin < 2) || isempty(x)
    x=linspace(0,1,1000)+x0;
else
    assert(isnumeric(x),'ERROR: independent grid must be numeric');
end

if object.Order == 0
    y=x-x0;
else    
    A=object.Parameter(1,:);
    A=[A(end:-1:1) 0];
    IA=polyint(conv(A,A));
    IA=polyval(IA,x)-polyval(IA,x0);
    B=object.Parameter(2,:);
    B=[B(end:-1:1) 1];
    IB=polyint(conv(B,B));
    IB=polyval(IB,x)-polyval(IB,x0);
    y=IA+IB;
end
y=object.Reference(2)+object.Slope*y;

% manage output
if nargout > 0
    varargout{1}=y;
    return
end

figure();
plot(x,y);

end