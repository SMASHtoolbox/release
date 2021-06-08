% errorbar2 Generate two-dimensional error bars
%
% This function generates two dimensional error bars.
%    errorbar2(x,y,dx,dy,hx,hy)
% The first four inputs ("x", "y", "dx", and "dy") are needed to define the
% error bar location and sizes.  Option inputs "hx" and "hy" control the
% fractional size of the boudnaries, e.g. the horizontal/vertical exent of
% the line orthogonal to the vertical/horizontal error bar. 
%
% Line options may be passed as name/value pairs at the
% end of the above inputs.  For exapmle, line color may be changed as
% follows.
%    errorbar(...,'Color','k');
% All line properties can be changed in a error bar, but the marker
% property should be left at 'none'.  Data markers should be generated
% separately from the error bar.
%    plot(x,y);
%    errorbar(x,y,dx,dy);
% Error bars are generated in the current axes without clearning---it is
% not necessary to "hold" the axes beforehand.
%
% Specifying an output:
%    h=errorbar(...);
% returns a graphic handle to the error bar.  Although error bars appear as
% separate entitiies for each (x,y) value, they are actually rendered as a
% single line with NaN separators.
%
% See also Graphics
% 

%
% created January 22, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=errorbar2(x,y,dx,dy,hx,hy,varargin)

if nargin<3
   error('Invalid number of arguments')
end
if isempty(dx)
   dx=zeros(size(x));
end
if (nargin<4) || isempty(dy)
   dy=zeros(size(y));
end
if length(dx)==1
   dx=ones(size(x))*dx;
end
if length(dy)==1
   dy=ones(size(y))*dy;
end
if (nargin<5) || isempty(hx);
   hx=dy/4;
end
if (nargin<6) || isempty(hy);
   hy=dx/4;
end
if length(hx)==1
   hx=ones(size(x))*hx;
end
if length(hy)==1
   hy=ones(size(x))*hy;
end

N=18; % number of "points" in each error bar
M=size(x);
if M(1)==1
   M(2)=M(2)*N;
else
   M(1)=M(1)*N;
end
xerr=zeros(M);
yerr=zeros(M);
ii=1:length(x);
L=length(xerr);
jj=1:N:L;
xerr(jj)=x(ii)-dx(ii);yerr(jj)=y(ii);
xerr(jj+1)=x(ii)+dx(ii);yerr(jj+1)=y(ii);
xerr(jj+2)=NaN;yerr(jj+2)=NaN;
xerr(jj+3)=x(ii);yerr(jj+3)=y(ii)+dy(ii);
xerr(jj+4)=x(ii);yerr(jj+4)=y(ii)-dy(ii);
xerr(jj+5)=NaN;yerr(jj+5)=NaN;
xerr(jj+6)=x(ii)-hx(ii);yerr(jj+6)=y(ii)+dy(ii);
xerr(jj+7)=x(ii)+hx(ii);yerr(jj+7)=y(ii)+dy(ii);
xerr(jj+8)=NaN;yerr(jj+8)=NaN;
xerr(jj+9)=x(ii)-hx(ii);yerr(jj+9)=y(ii)-dy(ii);
xerr(jj+10)=x(ii)+hx(ii);yerr(jj+10)=y(ii)-dy(ii);
xerr(jj+11)=NaN;yerr(jj+11)=NaN;
xerr(jj+12)=x(ii)-dx(ii);yerr(jj+12)=y(ii)+hy(ii);
xerr(jj+13)=x(ii)-dx(ii);yerr(jj+13)=y(ii)-hy(ii);
xerr(jj+14)=NaN;yerr(jj+14)=NaN;
xerr(jj+15)=x(ii)+dx(ii);yerr(jj+15)=y(ii)+hy(ii);
xerr(jj+16)=x(ii)+dx(ii);yerr(jj+16)=y(ii)-hy(ii);
xerr(jj+17)=NaN;yerr(jj+17)=NaN;

% plot 2D error bars
%h=plot(xerr,yerr,varargin{:});
h=line(xerr,yerr,'Color','k');
try
    if numel(varargin)>0
        set(h,varargin{:});
    end
catch
    error('ERROR: invalid line setting(s)');
end

% manage output
if nargout>0
    varargout{1}=h;
end
