% sinc Sinc function
%
% This function calculates y=sin(x)/x for all values of x.
%    y=sinc(x);
% The input "x" must be a real floating point array.  The output "y" is an
% array of the same size/shape as "x" with the same floating point
% precision.
%
% The normalized sinc function y=sin(pi*x)/(pi*x) can be requested with a
% second input argument.
%    y=sinc(x,'normalized');
% Calling this function with no inputs or outputs:
%    sinc();
% creates a plot of both functions.
%
% See also SMASH.SignalAnalysis
%

%
% created February 22, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=sinc(x,normalized)

% manage input
if (nargin == 0) && (nargout == 0)
    figure();
    x=linspace(-10*pi,10*pi,1000);
    y1=packtools.call('sinc',x);
    y2=packtools.call('sinc',x,'normalized');
    plot(x,y1,x,y2);
    xlabel('x');
    ylabel('y');
    legend('Standard sinc','Normalized sinc');
    return
end

assert(nargin > 0,'ERROR: insufficient input');
assert(isfloat(x) && isreal(x),...
    'ERROR: input must be a real floating point array');

if (nargin < 2) || isempty(normalized) || strcmpi(normalized,'standard')
    normalized=false;
elseif strcmpi(normalized,'normalized')
    normalized=true;
else
    error('ERROR: invalid normalization');
end


% numeric thresholds
persistent threshold
if isempty(threshold)
    threshold=[eps('double') eps('single')];
    threshold=sqrt(6*threshold); % Taylor series expansion
end

% manage output
if normalized
    x=pi*x;
end

y=ones(size(x));
switch class(x)
    case 'double'
        k=(abs(x) > threshold(1));
        y(k)=sin(x(k))./x(k);
    case 'single'
        k=(abs(x) > threshold(2));
        y(k)=sin(x(k))./x(k);
        y=single(y);
end
varargout{1}=y;

end