% modify Modify time axes of scan
%
% This method modifies the time axes of a LUNA scan.  The time step between
% points and the total time range are specified as follows.
%     >> object=modify(object,step,[tmin max]);
% Empty and omitted inputs allow particular settings to remain fixed.
%     >> object=modify(object,step); % change step, range remains the same
%     >> object=modify(object,step,[]); % same as above
%     >> object=modify(object,[],[tmin tmax]); % change range, step remains the same
% Any modification changes the object's IsModified property from false
% to true, indicating that the object may differ from the data stored in
% the source file.
%
% Step values must always be greater than zero.  Direct interpolation is
% applied when the requested step is less than or equal to the current
% step.  If the requested step size is larger than the current value, low
% pass filtering is applied before interpolation to prevent aliasing.
%
% Time ranges are always specified with two values, and infinite values are
% permitted.
%      - [-inf tmax] specifies all times <= tmax
%      - [tmin +inf] specifies all times >= tmin
%      - [-inf +inf] specifies all times (equivalient to [])
% The two values must be different (tmax > tmin).
%
% See also LUNA
%

%
% created April 30, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function object=modify(object,step,range)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

if isempty(step)
    % keep going
else
    assert(SMASH.General.testNumber(step,'positive','notzero'),...
        'ERROR: invalid step');
end

if (nargin<3) || isempty(range)
    range=[max(object.Time) min(object.Time)];
end
assert(isnumeric(range) && numel(range)==2 && (diff(range)~=0),...
    'ERROR: invalid range');
range=sort(range);
range(1)=max(range(1),object.Time(1));
range(2)=min(range(2),object.Time(end));

% enforce uniform time base
dt=(object.Time(end)-object.Time(1))/(numel(object.Time)-1);
if isempty(step)
    step=dt;
end
t1=object.Time(1):dt:object.Time(end);
y=object.LinearAmplitude;
y=interp1(object.Time,y,t1);

% time revision 
if step>dt
    sigma=4*(step/dt);
    L=3*round(sigma);
    x=-L:L;
    weight=exp(-x.^2/(2*sigma^2));
    weight=weight(:)/sum(weight);
    y=conv(y,weight,'same');    
end

t2=range(1):step:range(2);
y=interp1(t1,y,t2,'linear');

% store results
object.Time=t2;
object.LinearAmplitude=y;
object.IsModified=true;

end