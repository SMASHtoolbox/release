% getfilename : system dependent frontend to uigetdir
function dirname=getdirname(varargin)

switch lower(computer)
    case 'mac'
        dirname=native_uigetdir(varargin{:});
        %dirname=uigetdir(varargin{:});
    otherwise
        dirname=uigetdir(varargin{:});
end