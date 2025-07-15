% generate Generate frequency spectrum
%
% This method generates a complex frequency spectrum from the source data.
%    generate(object,numpoints);
% The input "numpoints" indicates the minimum number of frequency grid
% points (default is 1000).  
%
% NOTE: this method is automatically called at object creation.  Subsequent
% use is permitted for enhanced spectrum gridding.
%
% See also SinusoidFit
%

%
% created February 22, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function generate(object,numpoints)

% manage input
if (nargin < 2) || isempty(numpoints)
    numpoints=1000;
else
    assert(SMASH.General.testNumber(numpoints,'positive','integer','notzero'),...
        'ERROR: invalid number of frequency points');
    numpoints=max(numpoints,100);
end

% generate spectrum
new=fft(object.Source,...
    'NumberFrequencies',[numpoints inf],'SpectrumType','complex');
object.Spectrum=SMASH.SignalAnalysis.SignalGroup(new,new);
object.Spectrum.Legend={'Original','Remainder'};

end