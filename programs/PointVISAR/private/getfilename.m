% getfilename : system dependent frontend to uigetfile
function [filename,pathname,filterindex]=getfilename(varargin)

switch lower(computer)
    case 'mac'
        [filename,pathname,filterindex]=native_uigetfile(varargin{:});
        %[filename,pathname,filterindex]=uigetfile(varargin{:});
    otherwise
        [filename,pathname,filterindex]=uigetfile(varargin{:});
end