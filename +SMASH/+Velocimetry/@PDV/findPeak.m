% findPeak Find peak in a data set
%
% This method finds a *single* peak in a data set.
%    report=findPeak(data);
% The input "data" may be an object with Grid and Data fields (numeric
% arrays) or a two-column table.  The output is a structure with fields
% Location, Amplitude, and Width.
%
% Several peak analysis modes are supported.
%    -'centroid' iternatively calculates the centroid, refining the
%    horizontal range on each pass (moderate speed and moderate to high
%    reliability)
%    -'maximum' reports the maximum location (fast but unreliable).
%    -'parabola' uses a parabolic fitting around the maximum location
%    (moderate speed, low reliability).
%    -'gaussian' uses a gaussian fittting starting from the maximum
%    location (lowest speed, moderate to high reliability)
% Analysis mode is specified by name/value pair.
%    object=findPeak(data,'Mode',value);
% The default mode is 'centroid'.
%
% NOTE: several analysis modes may behave strangely when the data set
% contains more than one peak.  Centroid analysis is more robust to
% multiple peaks, but the results should be used with caution.
%
% Analysis options are also specified by name/value pair.
%    object=findPeak(data,name,value,...);
% Calling this method with an empty data set:
%    option=findPeak([]);
% returns an options structure.  This structure can be passed in subsequent
% calls:
%    report=findPeak(data,option);
% for quicker input processing (all error checks are bypassed).
%
% Examples:
%    <a href="matlab:SMASH.System.showExample('findPeakDemo','+SMASH/+Velocimetry/@PDV')">Peak demonstration</a>
%
% See also PDV
%


%
% created February 12, 2018 by Daniel Dolan (Sandia National Laboratories
%
function report=findPeak(data,varargin)

%% manage input
assert(nargin > 0,'ERROR: insufficient input');

if isempty(data)
    % do nothing
elseif isobject(data)
    try
        data=[data.Grid(:) data.Data(:)];
    catch
        error('ERROR: unable to create data table from input object');
    end
else
    assert(isnumeric(data) && (size(data,2) == 2),...
        'ERROR: invalid data table')
end

Narg=numel(varargin);
if (Narg == 1) && isstruct(varargin{1})
    option=varargin{1};   
else
    assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
    option.Mode='centroid';
    option.AmplitudeThreshold=0.50;
    option.MinPoints=3;
    option.MaxIteration=10;
    option.LocationTolerance=1e-3;
    option.WidthScale=2;
    option.MinWidth=0;
    for n=1:2:Narg
        % more rigorous parameter testing is needed here...
        name=varargin{n};
        assert(isvarname(name) && isfield(option,name),'ERROR: invalid name');
        value=varargin{n+1};
        option.(varargin{n})=value;
    end    
end

%% perform analysis
if isempty(data)
    report=option;
    return
end

data=sortrows(data,1);
x=data(:,1);
y=data(:,2);

if option.MinWidth == 0
    dx=(x(end)-x(1))/(numel(x)-1);
    option.MinWidth=option.MinPoints*dx;
end

[amplitude,index]=max(y);
location=x(index);
%left=index;
%right=index;
left=1;
right=numel(x);
%enforceBounds();

switch option.Mode       
    case 'maximum'
        % location and amplitude already known
        width=(x(right)-x(left))/2;
    case 'centroid'
        old=inf;
        for n=1:option.MaxIteration
            %enforceBounds();
            keep=left:right;           
            xn=x(keep);
            yn=y(keep);
            area=trapz(xn,yn);
            if area == 0
                report.Amplitude=0;
                report.Location=mean(x);
                report.Width=max(x)-min(x);
                return
            end
            weight=yn/area;
            location=trapz(xn,xn.*weight);
            width=sqrt(trapz(xn,(xn-location).^2.*weight));            
            width=max(width,option.MinWidth);
            if abs(old-location) <= (width*option.LocationTolerance)
                break
            end
            old=location;
            inside= abs(x-location) <= option.WidthScale*width;            
            left=find(inside,1,'first');
            if isempty(left)
                left=1;
            end
            right=find(inside,1,'last');
            if isempty(right)
                right=numel(x);
            end
        end           
        [~,k]=min(abs(x-location));
        amplitude=y(k);
%         k=min(k);
%         x1=x(k);
%         y1=y(k);
%         x2=x(k+1);
%         y2=y(k+1);
%         %         if location >= x(k)
%         %             x1=x(k);
%         %             y1=y(k);
%         %             x2=x(k+1);
%         %             y2=y(k+1);
%         %         else
%         %             x1=x(k-1);
%         %             y1=y(k-1);
%         %             x2=x(k);
%         %             y2=y(k);
%         %         end
%         w=(location-x1)/(x2-x1);
%         amplitude=(1-w)*y1+w*y2;
    case 'parabola'
        % normalize data
        xr=x(1);
        Lx=x(end)-x(1);
        xn=(x-xr)/Lx;
        yr=min(y);
        Ly=max(y)-yr;
        yn=(y-yr)/Ly;   
        % parabolic fit
        b=polyfit(xn,yn,2);
        location=-b(2)/(2*b(1));
        amplitude=polyval(b,location);
        width=abs(1/(2*b(1))); % latus rectum
        % undo normalization
        location=Lx*location+xr; % undo normalization
        amplitude=Ly*amplitude+yr;
        width=Lx*width;    
    case 'gaussian'
        % normalize data
        xr=x(1);
        Lx=x(end)-x(1);
        xn=(x-xr)/Lx;
        location=(location-xr)/Lx;
        sigma2min=(option.MinWidth/Lx)^2;
        yr=min(y);
        Ly=max(y)-yr;
        yn=(y-yr)/Ly;
        % gaussian fit       
        guess(1)=asin(2*location-1);        
        guess(2)=0;
        result=fminsearch(@GaussianResidual,guess,...
            optimset('TolX',option.LocationTolerance));
        [~,param]=GaussianResidual(result);
        % undo normalization
        location=param(3)*Lx+xr;
        amplitude=sum(param(1:2))*Ly+yr;
        width=param(4)*Lx;
    otherwise
        error('ERROR: invalid peak analysis mode');
end
    function enforceBounds()
        for kk=left:-1:1
            if y(kk) < (amplitude*option.AmplitudeThreshold)
                break
            end
        end
        if ~isempty(kk)
            left=kk;
        end
        for kk=right:+1:numel(x)
            if y(kk) < (amplitude*option.AmplitudeThreshold)
                break
            end
        end
        if ~isempty(kk)
            right=kk;
        end
        while numel(left:right) < option.MinPoints
            if left > 1
                left=left-1;
            end
            if right < numel(x)
                right=right+1;
            end
        end
    end
    function [chi2,param,fit]=GaussianResidual(p)
        basis=ones(numel(xn),2);
        x0=(1+sin(p(1)))/2;        
        sigma2=sigma2min+p(2)^2;
        basis(:,2)=exp(-(xn(:)-x0).^2/(2*sigma2));
        A=basis \ yn(:);
        fit=basis*A;
        chi2=mean((yn(:)-fit).^2);
        param=[A(1) A(2) x0 sqrt(sigma2)];
    end
  
 report=struct('Location',location,'Amplitude',amplitude,'Width',width);

end