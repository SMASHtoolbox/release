% SMOOTH Smooth SignalGroup Data
%
% This method smooths the Data array in a SignalGroup object, removing high
% frequency content.  The general calling syntax is:
%    >> object=smooth(object,choice,value);
% Three smoothing choices are supported.
%    -'mean' performs local averaging (value specifies full width)
%    -'median' uses local median smoothing (value specifies full width)
%    -'kernel' uses value as a convolution kernel.
% The last choice enables a variety of customizable operations to be
% performed.  For example, an approximate numerical derivative can be
% calculated as:
%    >> derivative=smooth(object,'kernel',[-1 0 +1]/(2*h));
% where h the grid spacing.  Another example, DC removal, is show below.
%    >> kernel=[0 0 0 1 0 0 0]-repmat(1/7,[1 7]);
%    >> new=smooth(object,'kernel',kernel);
%
% See also SignalGroup, sharpen
%

%
% created November 24, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function object=smooth(object,varargin)

% verify uniform grid
object=makeGridUniform(object);

for n=1:object.NumberSignals
    %temp=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));
    temp=split(object,n);
    temp=smooth(temp,varargin{:});
    object.Data(:,n)=temp.Data;
end

object=updateHistory(object);

end