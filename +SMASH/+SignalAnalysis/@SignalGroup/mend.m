% mend Remove NaN data from a SignalGroup object
%
% This function removes NaN data in a SignalGroup object.  
%    object=mend(object);
% NaN values bracketed by standard entries are replaced by linear
% interpolation; NaN entries that extent to the grid boundary are replaced
% with the first numeric value.
%
% NOTE: this method requires the Data property contain at least one numeric
% value!
%
% See also Signal, merge
%

%
% created January 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=mend(object)

for n=1:object.NumberSignals
    temp=SMASH.SignalAnalysis.Signal(object.Grid,object.Data(:,n));
    temp=mend(temp);
    object.Data(:,n)=temp.Data;
end

object=updateHistory(object);

end