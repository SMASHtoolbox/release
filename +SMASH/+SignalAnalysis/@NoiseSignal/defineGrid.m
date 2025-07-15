% defineGrid Define noise grid
%
% This method defines the grid points where noise is evaluated.  It is
% called automatically when a NoiseSignal is created and can be recalled to
% change the grid without created a new object.
%    object=defineGrid(object,t);
%
% See also NoiseSignal
%

%
% created March 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function object=defineGrid(object,Grid)

% manage input
assert(nargin==2,'ERROR: invalid number of inputs');
assert(isnumeric(Grid),'ERROR: invalid Grid');
Grid=sort(Grid(:));
Data=nan(size(Grid));
object.Measurement=reset(object.Measurement,Grid,Data);

N=numel(Grid);
spacing=(Grid(end)-Grid(1))/(N-1);
N2=pow2(nextpow2(N));

object.Npoints=N;
object.Npoints2=N2;

object.NyquistValue=1/(2*spacing);
f=[0:(N2/2) -(N2/2-1):-1];
f=f(:)/(N2*spacing);
object.ReciprocalGrid=f;

%object.ReciprocalGrid=(-N2/2):(+N2/2-1);
%object.ReciprocalGrid=object.ReciprocalGrid(:)/(N2*spacing);
%object.NyquistValue=abs(object.ReciprocalGrid(1));
%object.ReciprocalGrid=fftshift(object.ReciprocalGrid);

end