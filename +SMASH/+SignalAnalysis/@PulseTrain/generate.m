% generate Generate pulse train
%
% This method generates a pulse train signal.
%    result=generate(object);
% The output "result" is a Signal object.
%
% NOTE: this method is automatically called by the dependent property
% Output.  There should be no reason for user to call the method directly.
%
% See also PulseTrain
%

%
% created April 25, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function result=generate(object,varargin)

% generate result
t=object.Grid;
tr=rem(t-t(1)-object.Shift,object.Period);
signal=zeros(size(tr));

start=0;
stop=start+object.Rise;
index=(tr >= start) & (tr < stop);
signal(index)=tr(index)/object.Rise;

start=stop;
stop=start+object.Hold;
index=(tr >= start) & (tr < stop);
signal(index)=1;

start=stop;
stop=start+object.Fall;
index=(tr >= start) & (tr < stop);
signal(index)=(stop-tr(index))/object.Fall;

signal(signal > 1)=1;
signal(signal < 0)=0;

% manage pulse shaping
if ~isempty(object.ShapeFcn)
    tn=tr/sum(object.Parameter(1:3));
    index=(tn >= 0) & (tn <= 1);
    temp=feval(object.ShapeFcn,tn(index));
    signal(index)=signal(index).*temp;
end

% manage output
persistent master
if isempty(master)
    master=SMASH.SignalAnalysis.Signal([],1:10);
end

signal=object.Baseline+object.Amplitude*signal;
result=reset(master,t,signal);

end