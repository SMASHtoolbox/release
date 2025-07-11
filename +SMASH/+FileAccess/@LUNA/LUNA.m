% This class creates objects for displaying and analyzing fiber scans from
% a LUNA optical backscatter reflectomer.  LUNA objects are created from a
% source file:
%     >> object=LUNA(filename);
% Binary (*.obr) and text files are both accepted.  If no file is
% specified, the user is prompted to select one.
%
% LUNA objects allow fiber scans to be:
%     -displayed (view method)
%     -transferred to a custom time axes (modify method)
%     -analyzed for peaks (locate method).
%     -stored in a compact, portable file (store method)
% Refer to the specific methods for more information.
%
% See also SMASH.FileAccess
%

%
% created April 29, 2015 by Daniel Dolan (Sandia National Laboratories)
%
classdef LUNA
    properties (SetAccess=protected)     
        SourceFile % LUNA scan file
        FileHeader % Scan file header
        IsModified % Logical indicator of modified time axes 
        Time % Round trip transit time [nanoseconds]     
        LinearAmplitude % Fractional signal per unit length [1/millmeters]
    end
    %%
    properties
        GroupIndex = 1.4682 % Group refractive index
    end
    methods
        function object=set.GroupIndex(object,value)
            assert(isnumeric(value) && isscalar(value) && (value >= 1),...
                'ERROR: invalid group index');
            object.GroupIndex=value;                
        end
    end 
    %%
    properties (SetAccess=protected, Dependent=true)
        Distance % Physical distance [meters]
    end
    methods
        function value=get.Distance(object)
            persistent c0
            if isempty(c0)
                c0=SMASH.Reference.PhysicalConstant('c0','SI');
            end
            value=object.Time/2;
            value=value/1e9*c0/object.GroupIndex;            
        end
    end
    %%
    methods (Hidden=true)
        function object=LUNA(filename,varargin)
            if nargin < 1
                filename='';
            elseif strcmp(filename,'-empty') % empty object
                return
            elseif isstruct(filename)
                object=packtools.call('LUNA','-empty');
                name=fieldnames(filename);
                for n=1:numel(name)
                    if isprop(object,name{n})
                        object.(name{n})=filename.(name{n});
                    end                    
                end
                return
            end
            object=read(object,filename,varargin{:});
        end
        varargout=read(varargin);
    end    
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
end