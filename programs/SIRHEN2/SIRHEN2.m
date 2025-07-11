% SIRHEN2 Sandia InfraRed HeterodynE aNalysis program, version 2.0
%
% This program analysis Photonic Doppler Velocimetry (PDV) meaasurements,
% also known as heterodyne velocimetry.  The program is called with no
% input or output arguments.
%    SIRHEN2
% 
% See also loadSMASH, SIRHEN
%

%
% beta release May 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=SIRHEN2()

% launch GUI
%FontScale=1;
previous=SMASH.MUI.setFonts();
setProgramFont()
fig=createGUI();
SMASH.MUI.setFonts(previous);

% manage output
if isdeployed
    varargout{1}=0;
elseif nargout > 0
    varargout{1}=fig;
end

end