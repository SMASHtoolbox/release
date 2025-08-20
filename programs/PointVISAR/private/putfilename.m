function [filename,pathname,filterindex]=putfilename(varargin)

switch lower(computer)
    case 'mac'
        [filename,pathname,filterindex]=native_uiputfile(varargin{:});
        %[filename,pathname,filterindex]=uiputfile(varargin{:});
    otherwise
        [filename,pathname,filterindex]=uiputfile(varargin{:});
end