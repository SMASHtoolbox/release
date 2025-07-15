% DigitizerFile Class for accessing binary files created by digitizers
%
% Syntax:
%    >> object=DigitizerFile([filename],[format]);
% Supported formats include:
%    'acqiris'   - Acqiris binary files (*.h5)
%    'agilent'   - Agilent binary files (*.h5)
%    'dig'       - Nevada Test Site binary files (*.dig)
%    'lecroy     - LeCroy binary files (*.trc)
%    'keysight'  - Keysight binary files (*.h5)
%    'saturn'    - SATURN binary files (*.hdf)
%    'tektronix' - Tektronix binary files (*.wfm, *.isf)
%    'yokogawa'  - Yokogawa binary files (*.wfm)   
%    'zdas'      - ZDAS binary files (*.hdf)
%
% When no format is specified, the class tries to determine the format
% based on the file's extension.  Users will be prompted to select a format
% if multiple formats are associated with this extension.
%
% See also SMASH.FileAccess, probe, read, select 

%
classdef DigitizerFile < SMASH.FileAccess.File
    %%
    properties (SetAccess=protected)
        Format
    end
    properties (Hidden=true)
        FilterSpec={...
            '*.h5;*.H5;*.trc;*.TRC;*.wfm;*.WFM;*.isf;*.ISF;*.hdf;*.HDF','Digitizer files';...
            '*.*','All files';};
    end
    %%
    methods (Hidden=true)
        function object=DigitizerFile(filename,format)            
            object=object@SMASH.FileAccess.File();
            if nargin<1
                filename='';
            end
            if nargin<2
                format='';
            end
            object=select(object,filename,format);            
        end
    end
end