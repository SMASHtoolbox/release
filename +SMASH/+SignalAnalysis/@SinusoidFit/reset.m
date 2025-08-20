% reset Change signal source
%
% This method changes the signal source for a sinusoid fit.
%    reset(object,new);
% The input "new" must be a Signal object.  The associated spectrum is
% automatically updated, preserving the current number of frequency points.
% All defined sinusoid frequencies remain unchanged.
%
% See also SinusoidFit

%
% created February 25, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function reset(object,source)

% manage input
assert(nargin > 1,'ERROR: insufficient input');
assert(isa(source,'SMASH.SignalAnalysis.Signal'),...
    'ERROR: source must be a Signal object');

% update
if ~source.GridUniform
    object.Source=regrid(object.Source);
end
object.Source=source;
generate(object,numel(object.Spectrum.Grid));
scaleBasis(object);

end