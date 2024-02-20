% view Display noise signal or spectrum
%
% This method graphically displays a NoiseSignal object.  The default
% display is the noise signal stored in the Measurement property.
%    view(object);
%    view(object,'measurement');
% Changing the second input displays the frequency spectrum.
%    view(object,'spectrum');
%
% Graphic handles are returned as outputs (if present) in all cases.
%    hl=view(...);
%
% See also NoiseSignal
%

%
% created March 23, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode,varargin)

% manage input
if (nargin<2) || isempty(mode)
    mode='measurement';
end
assert(ischar(mode),'ERROR: invalid view mode');

% generate plot
switch lower(mode)
    case 'measurement'
        hl=view(object.Measurement,varargin{:});      
    case 'spectrum'      
        [f,P]=fft(object.Measurement);                
        temp=SMASH.SignalAnalysis.Signal(f,P);
        temp.GridLabel='Frequency';
        temp.DataLabel='Power';
        hl=view(temp,varargin{:});        
    case {'correlation' 'autocorrelation'}
        y=object.Measurement.Data;
        N=numel(y);
        %N2=pow2(nextpow2(N)+2);
        N2=pow2(nextpow2(1e6));
        yt=fft(y,N2);
        Q=ifft(yt.*conj(yt),'symmetric');
        Q=Q(1:N);
        duration=max(object.Measurement.Grid)-min(object.Measurement.Grid);
        t=linspace(0,duration/2,N);
        temp=SMASH.SignalAnalysis.Signal(t,Q/Q(1));
        temp.GridLabel='Delay';
        temp.DataLabel='Correlation';
        hl=view(temp,varargin{:});
    otherwise
        error('ERROR: invalid view mode');
end

% manage output
if nargout>0
    varargout{1}=hl;
end

end