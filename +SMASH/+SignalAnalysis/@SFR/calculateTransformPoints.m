% calculateTransformPoints Calculate number of FFT points
%
% This method calculates the number of points used in FFTs.
%    N2=calculateTransformPoints(object);
% The output "N2" is determined by the PeakPoints and RiseTime properties,
% accounting for the digital window shape.  Values are automatially
% increased to the next power of two.
%
% See SFR, setWindow
%
function N2=calculateTransformPoints(object)

% boxcar limit
N2=object.FullPoints*object.PeakPoints/2;

% window correction
Q1=object.Window.RiseScale;
Q0=1/sqrt(3); % boxcar value
N2=N2*(Q1/Q0);

% move to next power of two
N2=pow2(nextpow2(N2));

end