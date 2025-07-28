

function fft(varargin)

message={};
message{end+1}='ERROR: method not supported for SignalGroup objects';
message{end+1}='Use "split" method to create separate Signals for "fft" calculations';
error('%s\n',message{:});

end