% UNDER CONSTRUCTION
%
% gated image is constructed from a 
%
%   object=GatedImage(data);
 

%   obj=GatedImage(source); % specify source file/folder
%   obj=GatedImage(''); % select source file/folder

%   obj=GatedImage(file1,file2,...); 
%
%   obj=GatedImage(source1,source2,...); % existing objects

classdef GatedImage
    properties (SetAccess=protected)      
        Source = {}
    end
    %%
    properties
        Exposure % structure array
    end
    %%
    methods (Hidden=true)
        function object=GatedImage(varargin)
            if (nargin < 1) || isempty(varargin{1})
                source=SMASH.MUI.Dialog.browseDrive(...
                    'Name','Select image file/folder');
                if isnumeric(source)
                    return
                end
                varargin=source;
            end                  
            for n=1:numel(varargin)
                if isfolder(varargin{n})
                    new=object.readFolder(varargin{n});                    
                elseif isfile(varargin{n})
                    new=object.readFile(varargin{n}); 
                else
                    error('Feature not ready');
                    % UNDER CONSTRUCTION
                end
                object.Source{end+1}=new;                
            end           
        end
    end
    %%
    methods (Static=true)
        varargout=readFile(varargin)        
        varargout=readFolder(varargin)        
    end
end