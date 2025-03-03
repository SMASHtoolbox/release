% BANDPASS Bandpass filtering of Image data 
%
% Usage:
%   >> object=bandpass(object,range,type,[order],[spectra]);
% "range" are normalized low & high frequency cutoffs (0<value<1), 
% e.g. [0.001 0.25];
% "type" is for the following filters:
%   'ideal', 'gaussian', 'butterworth', 'chebyshev'; 
% "order" is an integer>=1 used for 'butterworth' & 'chebyshev' filters    
% "spectra" is to used to show power spectra:
%   'on' or 'off' (default)
% 
% See also IMAGE

% created July 24, 2014 by Tommy Ao (Sandia National Laboratories)
% updated April 21, 2016 by Tommy Ao

%
function object=bandpass(object,varargin)

% handle input
assert(nargin>=3,'ERROR: bandpass range and type are required');
if isnumeric(varargin{1}) && (numel(varargin{1})==2)  
    range=varargin{1};
    assert(range(2)>range(1),'ERROR: high frequency cutoff must greater than low frequency cutoff');
else
    error('ERROR: input bandpass range: [range(1) range(2)]');
end
if ischar(varargin{2})
    type=varargin{2};
else
    error('ERROR: input bandpass type: ideal, gaussian, butterworth');
end
if nargin>3 && ~isempty(varargin{3}) && isnumeric(varargin{3}) 
    order=varargin{3};
else
    order=1;
end
if nargin>4 && nargin<6 && ~isempty(varargin{4}) && ischar(varargin{4}) 
    spectra=varargin{4};
elseif nargin>5 && nargin<7 && ~isempty(varargin{5}) && ischar(varargin{5}) 
    spectra=varargin{5};
else
    spectra='off';
end

% verify uniform grid
object=makeGridUniform(object);

% remove NaN values
object.Data=fillmissing(object.Data,'linear',1,'EndValues','nearest');
object.Data=fillmissing(object.Data,'linear',2,'EndValues','nearest');

% find zeropadding size
m = max(size(object.Data)); % maximum dimension of data
P = 2^nextpow2(2*m); % find power-of-2 at least twice m

% calculate bandpassed data
BFdata=calculate_bandpass(object.Data,P,range,type,order,spectra);

% create bandpassed Image object
object.Data=BFdata(1:length(object.Grid2),1:length(object.Grid1));
object.DataLabel='Intensity (a.u.)';
object=updateHistory(object);

end

function F=calculate_bandpass(F,P,range,type,order,spectra)

% FFT bandpass type
[B,H1,H2]=bandpasstype(P,range,type,order);
if strcmpi(spectra,'on')
    figure;
    subplot(2,2,2);
    imagesc(fftshift(B)); caxis([min(min(abs(B))) max(max(abs(B)))]);
    title('Power spectrum of bandpass');
end

% FFT data
F=fft2(double(F),H1,H2);
if strcmpi(spectra,'on')
    subplot(2,2,1);
    imagesc(fftshift(log(abs(F)))); 
    caxis([0 max(max(log(abs(F))))]);
    title('Power spectrum of data');
end

% apply bandpass to data
F=B.*F;
if strcmpi(spectra,'on')
    subplot(2,2,3);
    imagesc(fftshift(log(abs(F)))); 
    caxis([0 max(max(log(abs(F))))]);
    title('Power spectrum of bandpassed data');
    set(gcf,'Units','normalized','Position',[0.05 0.05 0.90 0.90]);
    set(gcf,'Units','pixels'); 
end

% inverse FFT bandpassed data
F=real(ifft2(F));
F=F-min(F(:));

end


function [B,H1,H2]=bandpasstype(P,range,type,order)

% set up the meshgrid arrays needed for computing the required distances
PQ = [P, P];

% set bandpass range
D0H = round(range(1)*sqrt((PQ(1)^2+PQ(2)^2))/2); % highpass cutoff
D0L = round(range(2)*sqrt((PQ(1)^2+PQ(2)^2))/2); % lowpass cutoff

u = 0:(PQ(1)-1);
v = 0:(PQ(2)-1);
idx = find(u > PQ(1)/2); % compute the indices for use in meshgrid
u(idx) = u(idx) - PQ(1);
idy = find(v > PQ(2)/2);
v(idy) = v(idy) - PQ(2);
[V, U] = meshgrid(v, u); % compute the meshgrid arrays
D = sqrt(U.^2 + V.^2); % compute the distances D(U, V)

% calculate bandpass type
switch lower(type)
    case 'ideal'
        U = double(D <= D0L);
        V = double(D >= D0H);
    case 'gaussian'
        U = exp(-(D.^2)./(2*(D0L^2)));
        V = 1 - exp(-(D.^2)./(2*(D0H^2)));
    case 'butterworth'
        n = order;
        U = 1./(1 + (D./D0L).^(2*n));
        V = 1 - 1./(1 + (D./D0H).^(2*n));
    case 'chebyshev'
        n = order;
        epsilon = 1;
        TL = polyval(ChebyshevPoly(n),D./D0L);
        U = 1./(1 + epsilon^2.*TL.^2);
        TH = polyval(ChebyshevPoly(n),D./D0H);
        V = 1 - 1./(1 + epsilon^2.*TH.^2);
    otherwise
        error('Error: invalid bandpass choice');
end

B= U.*V;
[H1,H2]=size(B);

end
