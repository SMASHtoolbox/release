function emptyFlag = IsEmptyData(data)
% ISEMPTYDATA Returns true if data structure provided is empty.
%   Checks whether the data structure has any signals and their
%   corresponding times. If the data structure is empty, the function
%   returns true otherwise it returns false.

% Get the number of signals for the type of VISAR system
numSignals = GetNumberOfSignals(data.Type);

emptyCount = 0;

% For each signal, if the signal and time are empty add one to the count
for ii=1:numSignals
    if (isempty(data.Signal{ii}) | isempty(data.SignalTime{ii}))
        emptyCount = emptyCount + 1;
    end
end

% If the count is equal to the number of signals, then it is empty
if emptyCount == numSignals
    emptyFlag = true;
else
    emptyFlag = false;
end