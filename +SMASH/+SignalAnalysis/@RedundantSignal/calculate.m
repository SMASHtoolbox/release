% calculate Calculate source signal
%
% This method calculates the source signal from a set of redundant signals.
%    object=calculate(object);
% The process begins with a reverse transformation, mapping measured data
% to a set of equivalent signals.  These signals are combined by weighted
% average using the following rules.
%    -Measurements at their min/max values (as specified by the Range
%    property) are assigned zero weight.
%    -Non-zero weights are scaled by the inverse square of the noise ratio
%    assocated with each measurement.
%    -Regions where all measurements have zero weight are assigned
%    the value NaN.
% Calling this method updates the Source, Weight, and Status properties.
%
% See also RedundantSignal, SMASH.SignalAnalysis.Signal,
% SMASH.SignalAnalysis.SignalGroup
%

%
% created February 1, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function object=calculate(object)

noise=object.NoiseRatio;

% transform and weight measurements
data=cell(object.NumberSignals,1);
[data{:}]=split(object.Measurement);
weight=data;
for m=1:object.NumberSignals     
    s=data{m}.Data;
    w=repmat(1/noise(m).^2,size(s));
    % weighting based on *raw* measurements
    k=(s <= object.Range(m,1)) | (s >= object.Range(m,2));
    w(k)=0;
    % manage inf and/or nan
    k=~isfinite(s);
    w(k)=0;
    s(k)=0;
    % transform measurements
    s=(s-object.Parameter(m,3))/object.Parameter(m,2);
    % time shifting
    data{m}=reset(data{m},[],s);
    data{m}=shift(data{m},-object.Parameter(m,1));
    weight{m}=reset(weight{m},[],w);
    weight{m}=shift(weight{m},-object.Parameter(m,1));
end
data=SMASH.SignalAnalysis.SignalGroup(data{:});
data.Legend=object.Measurement.Legend;
weight=SMASH.SignalAnalysis.SignalGroup(weight{:});
weight.Legend=object.Measurement.Legend;

s=data.Data;
w=weight.Data;
w (w < 1) = 0; % eliminate clip artifacts from time shifting
drop=isnan(w);
s(drop)=0;
w(drop)=0;
factor=sum(w,2);
factor(factor == 0)=1;
w=w./factor;

s=sum(s.*w,2);
drop=(sum(w,2) == 0);
s(drop)=nan;
object.Source=SMASH.SignalAnalysis.Signal(data.Grid,s);
object.Status='complete';
object.Weight=reset(weight,[],w);

object.Weight.DataLabel='Weight';
object.Source.DataLabel='Source';



end