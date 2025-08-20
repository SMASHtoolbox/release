% demonstrate Generate demonstration
%
% This *static* method generates a demonstration object.
%    object=PDV.demonstrate();
% The output "object" is constructed from a synthetic signal for a linear
% velocity ramp.
%
% See also PDV
% 
function object=demonstrate()

% generate synthetic data
time=-500e-9:(1/10e9):1000e-9;
velocity=zeros(size(time));
t1=500e-9;
k=(time >= 0) & (time <= t1);
vmax=1e3;
velocity(k)=vmax*time(k)/t1;
k=(time > t1);
velocity(k)=vmax;

position=cumtrapz(time,velocity);
lambda=1550e-9;
phase=2*pi*(rand(1)+2*position/lambda);
signal=cos(phase);

object=packtools.call('PDV',time,signal);
object.Name='Demonstration';

end