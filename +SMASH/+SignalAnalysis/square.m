% square Genereate a square wave
%
% This function generates a square wave on a specified time base.
%    value=square(time,frequency,duty,delay);
% The output "value" is an array of zeros and ones of the same size/shape as
% the input "time".  The remaining inputs provide optional modifications to
% that square wave.
%    -"frequency" controls the signal frequency.  By default, one complete
%    cycle is generated over the time base.  Any finite number greater than
%    zero can be specified.
%    -"duty" controls the duty cycle; the default value is 0.50.  Any
%    number greater than zero and less than one can be specified.
%    -"delay" controls the signal time delay.  The default value is
%    zero, and any finite number can be specified.  
% Empty inputs indicate use of the default value.
%
% Signal amplitude and offset is managed outside this function.
%    value=offset+amplitude*square(time,...);
%
% See also SMASH.SignalAnalysis
%

%
% created September 1, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=square(time,frequency,duty,delay)

% manage input
assert(nargin > 0,'ERROR: insufficient input');
assert(isnumeric(time),'ERROR: invalid time base');

if (nargin < 2) || isempty(frequency)
    period=max(time)-min(time);
    frequency=1/period;
else
    assert(isnumeric(frequency) && isscalar(frequency) && (frequency > 0),...
        'ERROR: invalid frequency');
end

if (nargin < 3) || isempty(duty)
    duty=0.50;
else
       assert(isnumeric(duty) && isscalar(duty) && (duty > 0) && (duty < 1),...
        'ERROR: invalid duty cycle'); 
end

if (nargin < 4) || isempty(delay)
    delay=0;
else
    assert(isnumeric(delay) && isscalar(delay),'ERROR: invalid delay');
end

% generate square wave
out=zeros(size(time));
theta=frequency*(time-delay);
excess=theta-floor(theta);
index=(excess <= duty);
out(index)=1;

% manage output
if nargout == 0
    figure;
    plot(time,out);
    ylim([-0.05 1.05]);
else
    varargout{1}=out;
end

if nargout >= 2
    varargout{2}=SMASH.SignalAnalysis.Signal(time,out);
    varargout{2}.GridLabel='Time';
end

end