% butterworth Butterworth filter transfer function
%
% This function generates the transfer function for a Butterworth filter.
%    transfer=butterworth(cutoff,order);
% The inputs of the function define the filter's cutoff frequency and
% order.  The output "transfer" is a function handle that accepts frequency
% as its only input.  For example:
%    G=transfer(f);
% evaluates a defined Butterworth filter at the specified frequencies.
%
% NOTE: consistent units must be used for cutoff and frequency
% specifications.
%
% See also SMASH.SignalAnalysis
%

%
%
%
function out=butterworth(cutoff,order)

% manage input
assert((nargin >= 1) && ~isempty(cutoff),'ERROR: no cutoff frequency specified');
assert(SMASH.General.testNumber(cutoff,'positive','notzero'),...
    'ERROR: invalid cutoff frequency');

if (nargin < 2) || isempty(order)
    order=2;
else
    assert(SMASH.General.testNumber(order,'positive','notzero'),...
        'ERROR: invalid order');
end

% generate function handle
out=@(x) 1./sqrt(1+(x/cutoff).^(2*order));

end