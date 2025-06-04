% generateWindow Generate digital window
%
% This *static* method generates a digital window structure.  Windows may
% be defined manually through a function handle:
%    result=SFR.generateWindow(custom); "custom" evaluated from -0.5 to +0.5
% or by name.
%    result=SFR.generateWindow(name,param); % "param" input is optional
% The output structure "result" contains a function w(u) that returns the
% specified window for |u| <= 0.5 and zero everywhere else.  Scale factors
% associated with the window's shape are also stored in this structure.
%
% The following window names are supported.
%    -'boxcar', no parameters
%    -'blackman', no parameters
%    -'bspline', 1 parameter (order=3, 4, or 5)
%    -'connes', no parameters
%    -'flattop', 1 parmeter (order=3 or 5)
%    -'gaussian', 1 parameter (beta > 0)
%    -'hamming', no paramters
%    -'hann', no parameters
%    -'kaiser', 1 parameter (beta >= 1)
%    -'pcosine', 1 parameter (order >= 1)
%    -'psinc', 1 parameter (order >= 1)
%    -'singla' , 1 parameter (order=1 or 2)
%    -'triangle', 1 parameter (order >= 1)
%    -'tukey', 1 parameter (0 < beta < 1)
%    -'vorbis', no parameters
% The optional input "param" adjusts window shape.  Shape parameters are
% ignored for names that do not use parameters, e.g. the Hann window.
%
% References:
% -F. Harris, "On the use of windows for harmonic analysis with the
%     discrete Fourier transform", Proceedings of the IEEE 66, 51 (1978).
% -A. Nuttall, "Some windows with very good sidelobe behavior", IEEE
%  Transactions on Acoustics, Speech, and Signal Processing 29, 84 (1981).
% -A.W. Doerry, "Catalog of Window Taper Functions for Sidelobe Control",
% Sandia National Laboratories SAND2017-4042 (2017).
%
% See also SFR
%
function window=generateWindow(varargin)

% manage input
name='hann';
parameter=nan;
if nargin < 1      
    fprintf('Defaulting to Hann window\n');
elseif ischar(varargin{1})
    name=lower(varargin{1});
    if nargin > 1
        parameter=varargin{2};
    end
    assert(isnumeric(parameter) && isscalar(parameter),...
        'ERROR: invalid window parameter');
else
    assert(isa(varargin{1},'function_handle'),...
        'ERROR: invalid window function');    
    name='-custom';
end

% look up named windows
window.Name=name;
window.Parameter=parameter;

switch name
    case '-custom'
        window.Function=varargin{1};
    case 'boxcar'
        window.Function=@(t) ones(size(t));
        window.Name='Boxcar';
    case 'blackman'
        if exist('cospi','builtin')
            window.Function=@(t) 0.42+0.5*cospi(2*t)+0.08*cospi(4*t);
        else
            window.Function=@(t) 0.42+0.5*cos(2*pi*t)+0.08*cos(4*pi*t);
        end
        window.Name='Blackman';
    case 'bspline'
        if isnan(parameter)
            order=3;
        else
            order=parameter(1);
            assert(isscalar(order) && any(order == 3:5),...
                'ERROR: order must be 3, 4, or 5');
        end
        window.Function=@(t) bspline(t,order);
        window.Name=sprintf('B-spline (order %d)',order);
        window.Parameter=order;
    case 'connes'
        window.Function=@(t) (1-4*t.^2).^2;
        window.Name='Connes';
    case 'flattop'
        if isnan(parameter)
            order=3;
        else
            order=parameter(1);
            assert(any(order == [3 5]),'ERROR: order must be 3 or 5');
        end
        window.Function=@(t) flattop(t,order);
        window.Name=sprintf('Flat top (order %d)',order);
        window.Parameter=order;
    case 'gaussian'
        if isnan(parameter)
            parameter=1;
        else
            assert(parameter > 0,'ERROR: gaussian parameter must be > 0');
        end
        window.Function=@(t) exp(-2*parameter^2*t.^2);
        window.Parameter=parameter;        
    case 'hann'        
        a0=0.5;
        a1=0.5;
        if exist('cospi','builtin')
            window.Function=@(t) a0+a1*cospi(2*t);
        else
            window.Function=@(t) a0+a1*cos(2*pi*t);
        end
        window.Name='Hann';
    case 'hamming'
        a0=0.53836;
        a1=0.46164;
        if exist('cospi','builtin')
            window.Function=@(t) a0+a1*cospi(2*t);
        else
            window.Function=@(t) a0+a1*cos(2*pi*t);
        end
        window.Name='Hamming';
    case 'kaiser'
        if isnan(parameter)
            beta=16;
        else
            beta=parameter(1);
            assert((beta >= 1),'ERROR: beta must be >= 1');
        end
        window.Function=@(t) kaiser(t,beta);
        window.Name=sprintf('Kaiser (\\beta = %g)',beta);
        window.Parameter=beta;
    case 'pcosine'
        if isnan(parameter)
            order=2;
        else
            order=parameter(1);
            assert(order >= 1,'ERROR: order must be >= 1');
        end                    
        window.Function=@(t) cos(pi*t).^order;
        window.Name=sprintf('P-cosine (order %d)',order);
        window.Parameter=order;
    case 'psinc'
        if isnan(parameter)
            order=2;
        else
            order=parameter(1);
            assert(order >= 1,'ERROR: order must be >= 1');
        end
        window.Function=@(t) psinc(t,order);
        window.Name=sprintf('P-sinc (order %d)',order);
        window.Parameter=order;
    case 'singla'
        if isnan(parameter)
            order=1;
        else
            order=parameter(1);
            assert(any(order == [1 2]),'ERROR: order must be 1 or 2');
        end
        window.Function=@(t) singla(t,order);
        window.Name=sprintf('Singla (order %d)',order);
        window.Parameter=order;
    case 'triangle'
        if isnan(parameter)
            order=1;
        else
            order=parameter(1);
            assert(order >= 1,'ERROR: order must be >= 1 ');
        end
        window.Function=@(t) (1-2*abs(t)).^order;
        window.Name=sprintf('Triangle (order %d)',order);
        window.Parameter=order;
    case 'tukey'        
        if isnan(parameter)
            beta=0.5;
        else
            beta=parameter(1);
            assert((beta > 0) && (beta < 1),...
                'ERROR: alpha must be greater than 0 and less than 1');                       
        end
        window.Function=@(t) tukey(t,beta);     
        window.Name=sprintf('Tukey (alpha %d)',beta);
        window.Parameter=beta;
    case 'vorbis'
        window.Function=@(t) sin(pi/2*cos(pi*t).^2);
        window.Name='Vorbis';
    otherwise
        error('ERROR: unrecognized window name');
end

window.Function=@(t) window.Function(t).*double(abs(t) <= 0.5);

% rise time scaling
try
    area0=integral(@(z) abs(window.Function(z)),-0.5,+0.5);
catch
    error('ERROR: window must accept normalized times from -0.5 to +0.5');
end
area2=integral(@(z) z.^2.*abs(window.Function(z)),-0.5,+0.5);
window.RiseTime=2*sqrt(area2/area0);

% uncertainty scaling
area=integral(@(z) z.^2.*window.Function(z).^2,0,+0.5);
window.Uncertainty=1/(2*pi*sqrt(area));

end

%% advanced window functions
function out=flattop(t,order)

switch order  
    case 3
        a=[0.2811 0.5209 0.1980];
    case 5
        a=[0.21557895 0.41663158 0.277263158 0.083578947 0.006947368];
end

out=zeros(size(t));
for k=0:(order-1)
    out=out+a(k+1)*cos(2*pi*k*t);
end
out=out/sum(a);

end

function out=bspline(t,order)

out=ones(size(t));
switch order
    case 3
        k=abs(t) <= (1/6);
        out(k)=9/8*(2-24*abs(t(k)).^2);
        k=~k;
        out(k)=(9/8)*(3-12*abs(t(k))+12*abs(t(k)).^2);
        out=out*(4/9);
    case 4 % parzen window
        k=abs(t) < 0.25;
        tk=abs(t(k));
        out(k)=(8/3)*(1-24*tk.^2+48*tk.^3);
        k=~k;
        tk=abs(t(k));
        out(k)=(8/3)*(2-12*tk+24*tk.^2-16*tk.^3);
        out=out*(3/8);
    case 5
        k=abs(t) <= (1/10);
        tk=abs(t(k));
        out(k)=(25/384)*(46-1200*tk.^2+12000*tk.^4);
        k=(abs(t) > (1/10)) & (abs(t) <= (3/10));
        tk=abs(t(k));
        out(k)=(25/384)*(44+80*tk-2400*tk.^2+8000*tk.^3-8000*tk.^4);
        k=(abs(t) > (3/10));
        tk=abs(t(k));
        out(k)=(25/384)*(125-1000*tk+3000*tk.^2-4000*tk.^3+2000*tk.^4);
        out=out*(384/1150);
end

end

function out=kaiser(t,beta)

arg=sqrt(1-4*t.^2);
out=besseli(0,beta*arg,1)/besseli(0,beta,1).*exp(abs(beta*arg)-abs(beta));

end

function out=psinc(t,order)

out=ones(size(t));
threshold=6*eps(class(t));
arg=2*pi*t;
k=(abs(arg) > threshold);
out(k)=sin(arg(k))./arg(k);
out=out.^order;

end

function out=singla(t,order)

t=2*t;
switch order  
    case 1
        out=1-t.^2.*(3-2*abs(t));
    case 2
        out=1-abs(t).^3.*(10-15*abs(t)+6*t.^2);        
end

end

function out=tukey(t,alpha)

out=ones(size(t));
t0=alpha/2;
k=(abs(t) >= t0);
out(k)=(1+cos(pi*(abs(t(k))-t0)/(0.5-t0)))/2;

end