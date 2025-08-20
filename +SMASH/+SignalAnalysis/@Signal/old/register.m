% register Place Signal objects on a common Grid array
%
% This method accepts two or more Signal objects, determines a consistent
% time base, and places each object on that time base.
%    >> [object1,object2,...]=register(object1,object2,...);
%
% See also Signal
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=register(varargin)

% handle input
if nargin<2
    error('ERROR: at least two signals needed for time base registerment');
end

% determine common time base
left=-inf;
right=inf;
for n=1:nargin
    if isprop(varargin{n},'Grid') && isprop(varargin{n},'Data')
        time=varargin{n}.Grid;
        left=max([left min(time)]);
        right=min([right max(time)]);
    else
        error('ERROR: cannot register input #%d',n);
    end
end
if left==right
    error('ERROR: time bases cannot be overlapped');
end

N=0;
for n=1:nargin
    time=varargin{n}.Grid;
    keep=(time>=left) & (time<=right);
    N=max([N sum(keep)]);
end
time=linspace(left,right,N);
dt=(time(end)-time(1))/(numel(time)-1);

% limit signals to the common time base
varargout=varargin;
for n=1:nargin
    varargout{n}.Data=interp1(varargin{n}.Grid,varargin{n}.Data,time);
    varargout{n}.Grid=time;
    varargout{n}.GridDirection='normal';
    varargout{n}.GridUniform=true;
    varargout{n}.GridSpacing=dt;
    varargout{n}=updateHistory(varargout{n});
end

end

function varargout=register(varargin)

% handle input
if nargin<2
    error('ERROR: at least two signals needed for time base registerment');
end

% determine common time base
left=-inf;
right=inf;
for n=1:nargin
    if isprop(varargin{n},'Grid') && isprop(varargin{n},'Data')
        time=varargin{n}.Grid;
        left=max([left min(time)]);
        right=min([right max(time)]);
    else
        error('ERROR: cannot register input #%d',n);
    end
end
if left==right
    error('ERROR: time bases cannot be overlapped');
end

N=0;
for n=1:nargin
    time=varargin{n}.Grid;
    keep=(time>=left) & (time<=right);
    N=max([N sum(keep)]);
end
time=linspace(left,right,N);
dt=(time(end)-time(1))/(numel(time)-1);

% limit signals to the common time base
varargout=varargin;
for n=1:nargin
    varargout{n}.Data=interp1(varargin{n}.Grid,varargin{n}.Data,time);
    varargout{n}.Grid=time;
    varargout{n}.GridDirection='normal';
    varargout{n}.GridUniform=true;
    varargout{n}.GridSpacing=dt;
    varargout{n}=updateHistory(varargout{n});
end

end