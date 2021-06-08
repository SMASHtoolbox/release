% generateWindow Generate named window
%
% This *static* method generates a digital window by name.
%    result=SFR.generateWindow(name);
%    result=SFR.generateWindow(name,parameter);
% The input "name" is a required character array that selects one of the
% following digital windows.
%    -'boxcar', no parameters
%    -'blackman', no parameters
%    -'bspline', 1 parameter (order=3, 4, or 5)
%    -'connes', no parameters
%    -'flattop', 1 parmeter (order=3 or 5)
%    -'hamming', no paramters
%    -'hann', no paramters
%    -'kaiser', 1 parameter (beta >= 1)
%    -'pcosine', 1 parameter (order >= 1)
%    -'psinc', 1 parameter (order >= 1)
%    -'singla' , 1 parameter (order=1 or 2)
%    -'triangle', 1 parameter (order >= 1)
%    -'tukey', 1 parameter (0 < beta < 1)
%    -'vorbis', no parameters
% The optional input "parameter" adjusts the shape of the windows as noted
% above.
%
% The output "result" is a structure containing the window name, function,
% and any associated parameters.  The function handle in this structure
% calculates the window over normalized times from -0.5 to +0.5.
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
function result=generateWindow(name,parameter)

assert(ischar(name),'ERROR: invalid window name');
name=lower(name);

if nargin < 2
    parameter=[];
else
    assert(isnumeric(parameter),'ERROR: invalid window parameter');
end

result=struct('Name','','Function',[],'Parameter',nan);

switch name
    case 'boxcar'
        window=@(t) ones(size(t));
        result.Name='Boxcar';
        if ~isempty(parameter)
            warning('Boxcar window does not use parameters');
        end
    case 'blackman'
        if exist('cospi','builtin')
            window=@(t) 0.42+0.5*cospi(2*t)+0.08*cospi(4*t);
        else
            window=@(t) 0.42+0.5*cos(2*pi*t)+0.08*cos(4*pi*t);
        end
        result.Name='Blackman';
        if ~isempty(parameter)
            warning('Blackman window does not use parameters');
        end
    case 'bspline'
        if isempty(parameter)
            order=3;
        else
            order=parameter(1);
            assert(isscalar(order) && any(order == 3:5),...
                'ERROR: order must be 3, 4, or 5');
        end
        window=@(t) bspline(t,order);
        result.Name=sprintf('B-spline (order %d)',order);
        result.Parameter=order;
    case 'connes'
        window=@(t) (1-4*t.^2).^2;
        result.Name='Connes';
        if ~isempty(parameter)
            warning('Connes window does not use parameters');
        end
    case 'flattop'
        if isempty(parameter)
            order=3;
        else
            order=parameter(1);
            assert(any(order == [3 5]),'ERROR: order must be 3 or 5');
        end
        window=@(t) flattop(t,order);
        result.Name=sprintf('Flat top (order %d)',order);
        result.Parameter=order;
    case 'hann'        
        a0=0.5;
        a1=0.5;
        if exist('cospi','builtin')
            window=@(t) a0+a1*cospi(2*t);
        else
            window=@(t) a0+a1*cos(2*pi*t);
        end
        result.Name='Hann';
        if ~isempty(parameter)
            warning('Hann window does not use parameters');
        end
    case 'hamming'
        a0=0.53836;
        a1=0.46164;
        if exist('cospi','builtin')
            window=@(t) a0+a1*cospi(2*t);
        else
            window=@(t) a0+a1*cos(2*pi*t);
        end
        result.Name='Hamming';
        if ~isempty(parameter)
            warning('Hamming window does not use parameters');
        end
    case 'kaiser'
        if isempty(parameter)
            beta=16;
        else
            beta=parameter(1);
            assert((beta >= 1),'ERROR: beta must be >= 1');
        end
        window=@(t) kaiser(t,beta);
        result.Name=sprintf('Kaiser (\\beta = %g)',beta);
        result.Parameter=beta;
    case 'pcosine'
        if isempty(parameter)
            order=2;
        else
            order=parameter(1);
            assert(order >= 1,'ERROR: order must be >= 1');
        end                    
        window=@(t) cos(pi*t).^order;
        result.Name=sprintf('P-cosine (order %d)',order);
        result.Parameter=order;
    case 'psinc'
        if isempty(parameter)
            order=2;
        else
            order=parameter(1);
            assert(order >= 1,'ERROR: order must be >= 1');
        end
        window=@(t) psinc(t,order);
        result.Name=sprintf('P-sinc (order %d)',order);
        result.Parameter=order;
    case 'singla'
        if isempty(parameter)
            order=1;
        else
            order=parameter(1);
            assert(any(order == [1 2]),'ERROR: order must be 1 or 2');
        end
        window=@(t) singla(t,order);
        result.Name=sprintf('Singla (order %d)',order);
        result.Parameter=order;
    case 'triangle'
        if isempty(parameter)
            order=1;
        else
            order=parameter(1);
            assert(order >= 1,'ERROR: order must be >= 1 ');
        end
        window=@(t) (1-2*abs(t)).^order;
        result.Name=sprintf('Triangle (order %d)',order);
        result.Parameter=order;
    case 'tukey'        
        if isempty(parameter)
            beta=0.5;
        else
            beta=parameter(1);
            assert((beta > 0) && (beta < 1),...
                'ERROR: alpha must be greater than 0 and less than 1');                       
        end
        window=@(t) tukey(t,beta);     
        result.Name=sprintf('Tukey (alpha %d)',beta);
        result.Parameter=beta;
    case 'vorbis'
        window=@(t) sin(pi/2*cos(pi*t).^2);
        result.Name='Vorbis';
        if ~isempty(parameter)
            warning('Vorbis window does not use parameters');
        end
    otherwise
        error('ERROR: unrecognized window name');
end

result.Function=@(t) window(t).*localize(t);
    function out=localize(t)
        out=zeros(size(t));
        index=(abs(t) <= 0.5);
        out(index)=1;
    end
% 
I3=integral(result.Function,-0.5,+0.5);
% result.AmplitudeCorrection=1/I3;
% 
I4=integral(@(un) result.Function(un).^2,-0.5,+0.5);
result.BandwidthCorrection=I4/I3^2;
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
out=besseli(0,beta*arg)/besseli(0,beta);

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