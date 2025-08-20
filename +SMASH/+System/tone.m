% tone Generate an audio tone
%
% This function generates an audio tone.  
%    tone(frequency,duration);
% The default frequency is 700 Hz and the default duration is 0.1 seconds.
%
% There is a slight delay, typically less than a second, between
% the function call and sound production.  This delay is returned as an
% output
%    delay=tone(...);
% The delay does *not* include tone duration.
%
% See also SMASH.System
%

%
% created December 13, 2017 by Daniel Dolan (Sandia National Laboratories)
%    -This function produces sound during uiwait, but beep does not
%
function varargout=tone(frequency,duration)

tic
% manage input
if (nargin < 1) || isempty(frequency)
    frequency=700;
else
    assert(SMASH.General.testNumber(frequency),'ERROR: invalid frequency');    
end

if (frequency < 20) || (frequency > 20e3)
    warning('Frequency outside human hearing range.  Unexpected results may occur')
end

if (nargin < 2) || isempty(duration)
    duration=0.1;
end
assert(testNumber(duration,[0.01 inf]),'ERROR: invalid duration');

% generate sound
rate=2.5*frequency;
rate=max(rate,1000);
T=1/rate; % seconds
time=0:T:duration; % seconds

data=sin(2*pi*frequency*time);
sound(data,rate);

if nargout > 0
    varargout{1}=toc;
end

end

function pass=testNumber(value,range)

pass=isnumeric(value) && isscalar(value) && (value >= range(1)) && (value <= range(2));

end