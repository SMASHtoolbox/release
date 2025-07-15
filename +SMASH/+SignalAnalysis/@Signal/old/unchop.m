% unchop Analyze chopped signal
%
% This method calculates high/low values from a chopped signal.  These
% values are determined from step analysis of the smoothed signal.
%    report=unchop(object);
% The output "report" is a structure of amplitude, basline, and uncertainty
% values.
%
% Analysis parameters are specified by name/value pair.
%    [...]=unchop(object,name,value,...);
% Valid parameter names include:
%    -'Bandwidth' controls the frequency range.  The signal is smoothed and
%    decimated using this parameter.  The default value, Inf, indicates no
%    smoothing.
%    -'Fraction' controls the analysis region between chop transitions.
%    The default value, 0.5, uses the central 50% between rising/falling
%    edges for value and uncertainty calculations.  This parameter must be
%    greater than 0 and less than 1.
%    -'Direction' indicates if the signal increases ('positive') or
%    decreases ('negative') when the chopper is open.  The default value is
%    'positive'.
% 
% See also Signal, bin, smooth
%

%
% created April 23, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=unchop(object,varargin)

% manage input
option.Bandwidth=inf;
option.Fraction=0.20;
option.Direction='positive';

Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'bandwidth'
            assert(SMASH.General.testNumber(value,'positive','notzero'),...
                'ERROR: invalid bandwidth value');
            option.Bandwidth=value;
        case 'direction'
            assert(ischar(value),'ERROR: invalid direction value');
            switch lower(value)
                case 'positive'
                    option.Direction='positive';
                case 'negative'
                    option.Direction='negative';
                otherwise
                    error('ERROR: %s is not a valid direction',value);
            end
        case 'fraction'
            assert(isnumeric(value) && (value > 0) && (value < 1),...
                'ERROR: invalid fraction value')
            option.Fraction=value;
        otherwise
            error('ERROR: %s is not a valid option name',name);
    end
end

% decimation
object=regrid(object);
if isfinite(option.Bandwidth)    
    object=transfer(object,@(x) 1./(1+(x/option.Bandwidth).^2));
    t=object.Grid;
    nyquist=4*option.Bandwidth;
    T=1/(2*nyquist);
    warning('off','SMASH:alias');
    new=regrid(object,t(1):T:t(end));
    warning('on','SMASH:alias');
else
    new=object;
    warning('SMASH:slow',...
        'Chopper analysis at full bandwidth may be very slow');
end

% edge analysis
data=new.Data;
center=(max(data)+min(data))/2;
temp=sprintf('%d',new.Data > center);
if strcmpi(option.Direction,'positive')
    start=strfind(temp,'01')+1;    
    stop=strfind(temp,'10');
else
    start=strfind(temp,'10')+1;
    stop=strfind(temp,'01');
end
assert(~isempty(start) && ~isempty(stop),...
    'ERROR: missing chop transition(s)');
start=new.Grid(start);
stop=new.Grid(stop);
if numel(start) > numel(stop)
    start=start(1:numel(stop));
end

% extract on/off values
[on,off]=deal([]);
for k=1:numel(start)
    center=(stop(k)+start(k))/2;
    width=(stop(k)-start(k))/2;
    tc=center+[-1 +1]*option.Fraction*width/2;
    temp=crop(object,tc);    
    on=[on(:); temp.Data];
    temp=crop(object,tc+2*width);
    off=[off(:); temp.Data];
end
 
on=[mean(on) std(on)];
off=[mean(off) std(off)];
report.Amplitude=on(1)-off(1);
report.AmplitudeUncertainty=sqrt(on(2)^2+off(2)^2);
report.Baseline=off(1);
report.BaselineUncertainty=off(2);

% manage output
if nargout == 0
    disp(report);    
else
    varargout{1}=report;
    varargout{2}=new;
end

end