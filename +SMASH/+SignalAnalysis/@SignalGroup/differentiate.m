% DIFFERENTIATE Calculate numerical derivative
%
% This method numerically differentiates a SignalGroup object, resulting in
% a new object.
%    >> new=differentiate(object);
% By default, a centered difference approximation is used to calculate the
% derivative.  Polynomial smoothing (Savitzky-Golay method) of order k can
% be specified over N points as follows.
%    >> new=differentiate(object,[k N]); % Sa
% The number of points should be an odd number equal to or larger than k.
%
% See also SignalGroup, integrate
%

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories) 
% modified October 3, 2014 by Daniel Dolan
%   -fixed an index error bug
function object=differentiate(object,varargin)

for n=1:object.NumberSignals
    temp=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));
    temp=differentiate(temp,varargin{:});
    object.Data(:,n)=temp.Data;
end

object=updateHistory(object);

end