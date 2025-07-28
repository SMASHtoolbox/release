% SMASH supports many file formats.  Some of these formats are associated
% with a specific file type and extension, while others cover mutiple file
% types and/or extensions.  Specific associations, where they exist, are
% noted below.
%
% Text formats:
% 'block'            : Numeric data blocks stored in columns, separated by text headers 
% 'column'           : Numeric data stored in columns with an optional header
% 'oceanoptics'      : Ocean Optics spectrometer measurements
% 'optronicslab'     : OL-750 spectrometer measurments
% 'optronicslabdump' : OL-750 spectrometer screen dump
% 'tag'              : Tagged data blocks
%
% Signal formats:
%   'agilent'        : Agilent digitizer files (*.h5)
%   'keysight'       : Keysight digitizer files (*.h5)
%   'lecroy'         : Lecroy digitizer files (*.trc)
%   'saturn'         : Saturn Data Acquisition System files (*.hdf)
%   'tektronix'      : Tektronix digitizer files (*.isf, *.wfm)
%   'yokogawa'       : Yokogawa digitizer files (*.wfm)
%   'zdas'           : Z Data Acquisition System files (*.hdf)
%
% Image formats:
%   'film'           : Microdensitometer file scans (*.img, *.hdf, *.pff)
%   'graphics'       : Standard graphic format (*.jpg, *.tif, etc.)
%   'hamamatsu'      : Hamamatsu streak camera measurements (*.img)
%   'kentech'        : KenTech gated optical imager (*.hdf)
%   'optronis'       : Optronis streak camera measurements (*.imd)
%   'plate'          : Image plate measurementes (*.img)
%   'sbfp'           : Santa Barbara Focal Plan camera measurement (*.img)
%   'sydor'          : Sydor streak camera measurements (*.hdf)
%   'winspec'        : Princeton Instruments WinSpec measurements (*.spe)
%
% Special formats:
%   'dig'            : Nevada Test Site signal files (*.dig)
%   'pff'            : Portable File Format files (*.pff)
%   'sda'            : Sanda Data Archive files (*.sda)
%   'taf'            : Thrifty Array Format files (*.taf)
%
% See also SMASH.FileAccess
%

%
% created Deceber 5, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=SupportedFormats()

list={};
description={};

list{end+1}='block';
description{end+1}='Numeric column blocks (separated by text)';
list{end+1}='column';
description{end+1}='Numeric columns';
list{end+1}='oceanoptics';
description{end+1}='Ocean Optics spectrometer measurement';
list{end+1}='optronicslab';
description{end+1}='Optronics Laboratory spectrometer measurement';
list{end+1}='optronicslabdump';
description{end+1}='Optronics Laboratory spectrometer screen dump';
list{end+1}='tag';
description{end+1}='Tagged data blocks';

list{end+1}='acqiris';
description{end+1}='Acqiris digitizer signal';
list{end+1}='agilent';
description{end+1}='Agilent digitizer signal';
list{end+1}='dig';
description{end+1}='NTS digitizer signal';
list{end+1}='keysight';
description{end+1}='Keysight digitizer signal';
list{end+1}='lecroy';
description{end+1}='LeCroy digitizer signal';
list{end+1}='saturn';
description{end+1}='Saturn digitizer signal';
list{end+1}='tektronix';
description{end+1}='Tektronix digitizer signal';
list{end+1}='yokogawa';
description{end+1}='Yokogawa digitizer signal';
list{end+1}='zdas';
description{end+1}='ZDAS digitizer signal';

list{end+1}='film';
description{end+1}='Microdensitometer film scan';
list{end+1}='graphics';
description{end+1}='Standard graphic file';
list{end+1}='hamamatsu';
description{end+1}='Hammamatsu streak camera record';
list{end+1}='kentech';
description{end+1}='Kentch gated optical imager';
list{end+1}='optronis';
description{end+1}='Optronis streak camera record';
list{end+1}='plate';
description{end+1}='Image plate scan';
list{end+1}='sbfp';
description{end+1}='Santa Barabara Focal Plane camera record';
list{end+1}='sydor';
description{end+1}='Sydor streak camera record';
list{end+1}='winspec';
description{end+1}='Winspec CCD record';

list{end+1}='pff';
description{end+1}='Portable file format (associated with PFIDL)';
list{end+1}='sda';
description{end+1}='Sandia data archive (associated with SMASH toolbox)';
list{end+1}='taf';
description{end+1}='Thrifty array format (associated with SMASH toolbox)';

[list,index]=sort(list);
description=description(index);

if nargout==0
    fprintf('Supported formats: \n');
    fprintf('\t%s\n',list{:});
else
    varargout{1}=list;
    varargout{2}=description;
end

end