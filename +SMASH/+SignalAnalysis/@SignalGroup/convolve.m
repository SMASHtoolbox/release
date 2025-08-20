% * method disabled *
%
% See also SignalGroup

%
% created November 22, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function convolve(varargin)

message={};
message{end+1}='ERROR: method not supported for SignalGroup objects';
message{end+1}='Use "split" method to create separate Signals for "convolve" calculations';
error('%s\n',message{:});

end