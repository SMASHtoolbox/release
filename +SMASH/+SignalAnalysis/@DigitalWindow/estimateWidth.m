% hidden method
function value=estimateWidth(object,SamplePoints,PeakPoints)

% manage input
old=object.PrivatePoints;
if (nargin < 2) || isempty(SamplePoints)
    SamplePoints=object.SamplePoints;
else
    try
        object.SamplePoints=SamplePoints;
    catch ME
        throwAsCaller(ME);
    end
end

if (nargin < 3) || isempty(PeakPoints)
    PeakPoints=object.PeakPoints;
else
    try
        object.PeakPoints=PeakPoints;
    catch ME
        throwAsCaller(ME);
    end
end

% perform calculation
object.SamplePoints=SamplePoints;
object.PeakPoints=PeakPoints;

[S,f]=fft(object,[],'positive');
S=real(S);
S=S/S(1);
index=find(S < 0.5,1,'first')+[-1 0];
param=polyfit(f(index),S(index)-0.5,1);
f1=roots(param);

value=f1*object.SamplePoints;

% restore point settings
object.PrivatePoints=old;

end