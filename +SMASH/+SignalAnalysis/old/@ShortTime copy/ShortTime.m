% This class creates ShortTime objects for local analysis of
% one-dimensional scalar information.  Objects created  with this class
% have all properties/methods of the Signal superclass as well as the
% following capabilities.
%    -The "partition" method partitions the objects' Grid into local regions.
%    -The "analyze" method applies a specified function to these regions.
% For more information, refer the documentation for each method.
%
% The most direct way to create a ShortTime object is to pass numerical
% information directly.
%    >> object=ShortTime(Grid,Data);
% Information can also be imported from a data file.
%    >> object=ShortTime('import',filename,format,[record]);
%
%
% See also SMASH.SignalAnalysis.Signal, SMASH.FileAccess.SupportedFormats
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef ShortTime < SMASH.SignalAnalysis.Signal
    %%
    properties (SetAccess=?SMASH.General.DataClass)
        Partition; % Analysis partition structure  
    end  
    properties (Hidden=true)
        ShowWaitbar=false % Enable/disable waitbar display
        WaitbarIncrement=0.05 % Progress steps on waitbars
    end
    %%
    methods (Hidden=true)
        function object=ShortTime(varargin)
            object=object@SMASH.SignalAnalysis.Signal(varargin{:});
            object=makeGridUniform(object); % force uniform Grid spacing            
        end
    end
    %% protected methods
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
        varargout=convert(varargin);
    end
end