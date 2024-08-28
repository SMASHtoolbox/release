% characterize Sinusoid characterization
%
% This method characterizes redundant measurements using a sinusoid that
% spans a known range.
%    object=characterize(object,span); % use object data
%    object=characterize(object,span,ref); % use reference object
% The input "span" must be an array of two numbers that define the
% minimum and maximum sinusoid value.
%
% See also RedundantSignal, calculate
%

%
% created April 1, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function object=characterize(object,span,reference)

% manage input
assert(nargin >= 2,'ERROR: insufficient input');

assert(isnumeric(span) && (numel(span) == 2),...
    'ERROR: invalid span');
span=sort(span);
amplitude=diff(span)/2;
assert(amplitude > 0,'ERROR: invalid span');
baseline=mean(span);

if (nargin < 3) || isempty(reference)
    reference=object.Measurement;
else
    assert(isa(span,'SMASH.SignalAnalysis.SignalGroup'),...
        'ERROR: invalid reference object');
    assert(object.NumberSignals == reference.NumberSignals,...
        'ERROR: incompatible reference object');
end

object.Parameter(1,1)=0;
M=object.NumberSignals;
theta=nan(M,1);
for m=1:M
    % estimate frequency bound
    data=split(reference,m);
    bound=calculateFrequencyBound(data);
    fB=mean(bound);
    fA=diff(bound)/2;
    % discard clipped data
    s=data.Data;
    keep= (s > object.Range(m,1)) & (s < object.Range(m,2));
    s=s(keep);
    t=data.Grid(keep);
    % optimize frequency
    basis=ones(numel(t),1);
    q=[];
    fit=[];
    slack=fminsearch(@residual,0,optimset('TolX',1e-10));
    f=fB+fA*sin(slack);    
    theta(m)=atan2(q(3),q(2));
    if m > 1
        object.Parameter(m,1)=(theta(1)-theta(m))/(2*pi*f);
    end
    object.Parameter(m,2)=hypot(q(2),q(3))/amplitude;
    object.Parameter(m,3)=q(1)-object.Parameter(m,2)*baseline;
end
    function chi2=residual(z)
        f=fB+fA*sin(z);
        basis(:,2)=+cos(2*pi*f*t);
        basis(:,3)=-sin(2*pi*f*t);
        q=basis\s;
        fit=basis*q;
        chi2=mean((fit-s).^2);
    end
end

function fb=calculateFrequencyBound(data)

temp=fft(data,'RemoveDC',true,'NumberFrequencies',1e4);
[amplitude,index]=max(temp.Data);
threshold=0.50*amplitude;

for k=index:-1:1
    if temp.Data(k) < threshold
        break
    end
end
fb(1)=temp.Grid(k);

for k=index:numel(temp.Data)
    if temp.Data(k) < threshold
        break
    end
end
fb(2)=temp.Grid(k);

end