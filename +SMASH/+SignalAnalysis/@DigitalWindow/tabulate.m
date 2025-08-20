% tabulate Tabulate window and transform pair
%
% This method tabulates the window and its Fourier transform.
%   result=tabulate(object);
% The output "result" is a structure of lookup functions. Normalized time
% and frequency values can be passed directly to these functions.
%    window=result.Window(time);
%    transform=result.Transform(frequency);
%    conjugate=result.Conjugate(frequency);  
%
% See also DigitalWindow, calculateTransformPair
%
function result=tabulate(object)

result.Window=griddedInterpolant(object.Time,object.Data,...
    'linear','nearest');

[transform,frequency]=calculateTransformPair(object);
result.Transform=griddedInterpolant(frequency,real(transform),...
    'linear','nearest');
result.Conjugate=griddedInterpolant(frequency,imag(transform),...
    'linear','nearest');

end