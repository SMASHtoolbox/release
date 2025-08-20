% This class creates Short Time Fourier Transform (STFT) objects for
% representing the time-frequency content of a signal.  STFT objects are
% created from Signal/ShortTime objects or the information needed to create
% a Signal object.
%    object=ShortTime(source); % build from a source Signal/ShortTime object
%    object=ShortTime(Grid,Data); % build from numeric data
%    object=ShortTime(filename,format,record); % build from file
% Signal information is stored in the Measurement property.
%
% See also SMASH.SignalAnalysis, SMASH.SignalAnalysis.Signal,
% SMASH.SignalAnalysis.ShortTime
%

%
% created July 1, 2016 by Daniel Dolan (Sandia National Laboratories)
%
classdef STFT < SMASH.SignalAnalysis.ShortTime
    %%
    properties
        FFToptions = SMASH.General.FFToptions % FFT options object
        Normalization = 'global' % Power spectrum normalization ('global', 'local', or 'none')
    end  
    %%
    methods (Hidden=true)
        function object=STFT(varargin)
            object=object@SMASH.SignalAnalysis.ShortTime('-empty');
            if (nargin==1) && isa(varargin{1},'SMASH.SignalAnalysis.ShortTime')
                source=varargin{1};
            else
                source=SMASH.SignalAnalysis.ShortTime(varargin{:});
            end            
            name=properties(source);
            for n=1:numel(name)
                object.(name{n})=source.(name{n});
            end
            object.Name='STFT object';
            object.Measurement.GraphicOptions.Title='STFT object';
        end
    end
     %% hidden methods   
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% setters
    methods
        function object=set.FFToptions(object,value)
            assert(isa(value,'SMASH.General.FFToptions'),...
                'ERROR: invalid FFToptions setting');            
            object.FFToptions=value;
        end
        function object=set.Normalization(object,value)
            assert(ischar(value),'ERROR: invalid Normalization setting');
            value=lower(value);
            switch value
                case {'none' 'global' 'local'}
                    % valid choice
                otherwise
                    error('ERROR: invalid Normalization setting');
            end
            object.Normalization=value;
        end
    end
end