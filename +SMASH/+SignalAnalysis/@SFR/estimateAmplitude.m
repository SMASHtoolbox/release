% estimateAmplitude Estimate signal amplitude
%
% This method estimates coherent signal amplitude based on signal power.
% Amplitude calculations are performed using the current rise and step time
% settings.
%    value=estimateAmplitude(object);
% The output "value" is a two-column array [time amplitude].
%
% See also SFR, estimateNoise, setFrequencyBand
%
function varargout=estimateAmplitude(object)

report=setTimeScale(object);

object.PrivateAmplitude=process(object,@processStep);
    function out=processStep(tcenter,data)
        out=nan(numel(tcenter),2);
        start=0;
        while ~isempty(tcenter) && ~isnan(tcenter(1))
            signal=data(1:report.DurationPoints);
            start=start+1;
            out(start,1)=tcenter(1);
            out(start,2)=sqrt(2)*std(signal);
            tcenter=tcenter(2:end);
            data=data((1+report.StepPoints):end);
        end
    end

if nargout == 0
    plot(object,'amplitude');
else
    varargout{1}=object.PrivateAmplitude;
end

end