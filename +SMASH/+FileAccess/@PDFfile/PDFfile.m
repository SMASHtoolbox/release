% PDFfile PDF file class
%
% This class interacts with Portable Document File (*.pdf) files.  Class
% objects are linked to an *existing* file at creation.
%    object=PDFfile(filename);
%
% See also SMASH.FileAccess
%

classdef PDFfile < SMASH.Developer.SimpleHandle
    properties (SetAccess=protected)
        File % Existing PDF file name (absolute path)
    end
    methods (Hidden=true)
        function object=PDFfile(filename)
            % manage input
            assert(nargin > 0,'ERROR: no file name specified');
            if isstring(filename)
                filename=char(filename);
            end
            assert(ischar(filename),'ERROR: invalid file name');
            % error checking
            [location,name,ext]=fileparts(filename);
            assert(strcmpi(ext,'.pdf'),'ERROR: invalid file extension');
            current=pwd();
            CU1=onCleanup(@() cd(current));
            if isempty(location)
                location=current;
            end           
            try
                cd(location);
            catch
                error('ERROR: invalid file location');
            end
            filename=fullfile(location,[name ext]);
            assert(isfile(filename),'ERROR: requested file does not exist');           
            object.File=filename;           
        end
    end
    methods (Static=true)
        varargout=generate(varargin)
    end
end