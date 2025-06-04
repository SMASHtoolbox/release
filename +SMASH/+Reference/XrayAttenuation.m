% XrayAttenuation Access x-ray attenuation spectra
%
% This function provides the x-ray attenuation spectrum for a specified
% element.
%    data=XrayAttenuation(name); % element name (e.g., 'Iron')
%    data=XrayAttenuation(symbol); % element symbol (e.g., 'Fe')
%    data=XrayAttenuation(Z);    % element number (1-92).
% The output "data" is a two-column array of photon energy (keV) and
% attenuation coefficient (1/cm).  If no output is requested:
%    XrayAttenuation(...);
% the spectrum is plotted in a new figure window.
%
% Raw data obtained from NIST Standard Reference Database 126 [J.H. Hubbell
% and S.M. Seltzer, "Tables of X-Ray Mass Attenuation Coefficients and Mass
% Energy-Absorption Coefficients from 1 keV to 20 MeV for Elements Z = 1 to
% 92 and 48 Additional Substances of Dosimetric Interest" (1996).]
% available at https://dx.doi.org/10.18434/T4D01F.
%
% See also SMASH.Reference
%
function varargout=XrayAttenuation(selection)

% manage input
assert(nargin > 0,'ERROR: no element selected');
try
    info=packtools.call('PeriodicTable',selection);
catch ME
    throwAsCaller(ME);
end
file=info.Number;

% read table
if isnumeric(file)
    file=sprintf('z%02d.txt',file);
end

location=fileparts(mfilename('fullpath'));
location=fullfile(location,'data','XrayAttenuation');
file=fullfile(location,file);

data=SMASH.FileAccess.readFile(file,'column');
data=data.Data;
data(:,1)=1e3*data(:,1); % convert MeV to keV;

% manage output
if nargout == 0
    figure;
    plot(data(:,1),data(:,2));
    xlabel('Photon energy (keV)');
    ylabel('Attenuation (1/cm)');
    set(gca,'XScale','log','YScale','log');
    title(sprintf('%s (Z=%d)',info.Name,info.Number))
else
    varargout{1}=data;
end

end