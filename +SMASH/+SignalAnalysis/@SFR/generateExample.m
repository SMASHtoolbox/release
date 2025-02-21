% generateExample Generate example object
% 
% This *static* method generates example objects for SFR testing.  
%    object=SFR.generateExample(name,RMS);
% The input "name" indicates one of the following examples.
%    -'steady' is a constant-frequency signal (default).
%    -'slowchirp' is a signal where frequency increases linearly.
%    -'fastchirp' is a faster version of the above.
%    -'jump' is a signal with a discontinuous frequency change.
%    -'msteady' is a signal containing multiple constant frequencies, two
%    of which are close together and third much further away
%    -'nothing' is a signal with no content other than noise.
% The optional input "RMS" indicates the time-domain noise amplitude added
% to the unity-amplitude signal.  The default value is 0.10, and any value
% greater than 0 can be specified.
%
% Requesting a second output:
%    [object,source]=SFR.generateExample(...);
% returns an array "source" with at least two columns.  The first column is
% always the signal time base.  All other columns correspond to a frequency
% used in signal generation.
%
% See also SFR
%
function [object,source]=generateExample(name,RMS,amplitude)

% manage input
if (nargin < 1) || isempty(name)
    name='steady';
else
    assert(ischar(name),'ERROR: invalid example name');
    name=lower(name);
end

if (nargin < 2) || isempty(RMS)
    RMS=0.10;
else
    assert(testNumber(RMS),'ERROR: invalid SNR');
    assert(RMS > 0,'ERROR: SNR must be greater than zero');
end

if (nargin < 3) || isempty(amplitude)
    amplitude=1;
else
    assert(testNumber(amplitude) && (amplitude > 0),...
        'ERROR: invalid amplitude');
end

%
fs=80;
f1=fs/13;
f2=fs/10;
t=0:(1/fs):200;
t=t(:);
source=nan(numel(t),2);
source(:,1)=t;
switch name
    case {'steady1' 'steady'}
        f0=(f1+f2)/2;
        s=cos(2*pi*f0*t+pi/5);
        source(:,2)=f0;
    case 'steady2'
        f0=(f1+f2)/2;
        A=ones(size(t));
        t0=25;
        k=(t >= t0);
        A(k)=exp(-(t(k)-t0)/25);
        s=A.*cos(2*pi*f0*t+pi/5);
        source(:,2)=f0;
    case 'slowchirp'
        tc=mean(t);
        tau=1.5*tc;
        f=repmat(f1,size(t));
        t1=tc-tau/2;
        t2=tc+tau/2;
        f(t >= t2)=f2;
        k=(t >= t1) & (t < t2);       
        f(k)=f1+(f2-f1)*(t(k)-t1)/tau;
        phase=2*pi*cumtrapz(t,f)+pi/5;        
        s=cos(phase);
        source(:,2)=f;
    case 'fastchirp'
        tc=mean(t);
        tau=tc/5;
        f=repmat(f1,size(t));
        t1=tc-tau/2;
        t2=tc+tau/2;
        f(t >= t2)=f2;
        k=(t >= t1) & (t < t2);       
        f(k)=f1+(f2-f1)*(t(k)-t1)/tau;
        phase=2*pi*cumtrapz(t,f)+pi/5;        
        s=cos(phase);
        source(:,2)=f;
    case 'jump'
        s=cos(2*pi*f1*t+pi/5);
        source(:,2)=f1;
        k=(t >= (t(end)/2));       
        s(k)=cos(2*pi*f2*t(k)+pi/7);        
        source(k,2)=f2;
    case 'msteady'
        f1A=f1;
        f1B=1.01*fs;        
        s=cos(2*pi*f1A*t+pi/5)+cos(2*pi*f1B*t+pi/7)+0.10*cos(2*pi*f2*t+pi/11);
        source(:,2)=f1A;
        source(:,3)=f1B;
        source(:,4)=f2;
    case {'overlap1' 'overlap'}
        s1=cos(2*pi*f1*t+pi/5);        
        tc=mean(t);
        tau=1.5*tc;
        f=repmat(f1,size(t));
        t1=tc-tau/2;
        t2=tc+tau/2;
        f(t >= t2)=f2;
        k=(t >= t1) & (t < t2);
        f(k)=f1+(f2-f1)*(t(k)-t1)/tau;
        phase=2*pi*cumtrapz(t,f)+pi/7;        
        s2=cos(phase);
        s=0.10*s1+s2;
        source(:,2)=f;
    case 'overlap2'
        s1=cos(2*pi*f1*t+pi/5);
        tc=mean(t);
        tau=1.5*tc;
        f=repmat(f1,size(t));
        t1=tc-tau/2;
        t2=tc+tau/2;
        f(t >= t2)=f2;
        k=(t >= t1) & (t < t2);
        f(k)=f1+(f2-f1)*(t(k)-t1)/tau;
        phase=2*pi*cumtrapz(t,f)+pi/7;
        s2=cos(phase);
        s=s1+s2;
        source(:,2)=f;
    case 'nothing'
        s=zeros(size(t));
    otherwise
        error('ERROR: unknown example');
end
noise=SMASH.SignalAnalysis.NoiseSignal(t);
noise=defineTransfer(noise,'Bandwidth',fs/4);
noise.Amplitude=RMS;
noise=generate(noise);
s=amplitude*s+noise.Measurement.Data;

%
object=packtools.call('SFR',t,s);
%object.StepTime=object.RiseTime/2;

end