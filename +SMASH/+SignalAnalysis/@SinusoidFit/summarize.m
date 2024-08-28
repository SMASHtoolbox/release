% Summarize List sinusoid parameters
%
% This method lists the frequency, amplitude, and phase of all defined
% sinusoids.  Parameters can be printed in the command window:
%    summarize(object);
% or returned as output arguments.
%    [frequency,amplitude,phase]=summarize(object);
%
% See also SinusoidFit
%

%
% created February 25, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object)

% extract information
N=object.NumberSinusoids;
if N > 0
    frequency=object.Parameter(:,1);
    amplitude=object.Parameter(:,2);
    phase=object.Parameter(:,3);
else
    frequency=[];
    amplitude=[];
    phase=[];
end

% manage input
if nargout == 0
    if N > 0
        fprintf('%15s','Sinusoid','Frequency','Amplitude','Phase');
        fprintf('\n');                   
        for k=1:N
            fprintf('%15d%15g%15g%15g\n',k,frequency(k),amplitude(k),phase(k));
        end
    else
        fprintf('No sinusoids defined\n');
    end
else
    varargout{1}=frequency;
    varargout{2}=amplitude;
    varargout{3}=phase;
end

end