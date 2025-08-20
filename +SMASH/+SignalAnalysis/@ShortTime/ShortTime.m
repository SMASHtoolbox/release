% This class creates ShortTime objects for local analysis of
% one-dimensional information.  ShortTime objects are created from Signal
% objects or the information needed to create a Signal object.
%    object=ShortTime(source); % build from a source Signal
%    object=ShortTime(Grid,Data); % build from numeric data
%    object=ShortTime(filename,format,record); % build from file
% Signal information is stored in the Measurement property.
%
% See also SMASH.SignalAnalysis, SMASH.SignalAnalysis.Signal,
% SMASH.FileAccess.SupportedFormats
%

%
% created April 8, 2014 by Daniel Dolan (Sandia National Laboratories)
% signficantly revised June 26, 2016 by Daniel Dolan
%    -ShortTime is no longer a subclass of Signal, but instead stores a
%    Signal object inside the Measurement property.
%
classdef ShortTime
    %%
    properties
        Measurement % Measured signal (SMASH.SignalAnalysis.Signal object)
        Name = 'ShortTime object' % Object name (text)
        Comments = '' % Object comments (text)
    end
    properties (SetAccess=protected)
        Partition % Analysis partition settings (structure). Modify with the partition method
    end      
    properties
        % ProgressReport Report analysis progress
        % 
        % This property controls if/how analysis progress is reported.  The
        % default mode 'none' means the analyze methods runs with no status
        % reports.  Progress updates (in 1% intervals) are printed in the
        % command window when this property is set to 'console'.  Progress
        % is displayed in a separate window when this property is set to
        % 'dialog'.
        ProgressReport = 'none';
    end    
   methods
       function object=set.ProgressReport(object,value)
           ERRMSG='ERROR: invalid progress report type';
           assert(ischar(value),ERRMSG);
           value=lower(value);
           switch value
               case {'none' 'console' 'dialog'}
                   object.ProgressReport=value;
               otherwise
                   error(ERRMSG);
           end
       end
  
   end
    %%
    methods (Hidden=true)
        function object=ShortTime(varargin)
            if (nargin==1)
                if strcmpi(varargin{1},'-empty')
                    return % this mode is for subclass constructors
                end
                switch class(varargin{1})
                    case 'SMASH.SignalAnalysis.Signal'
                        object.Measurement=varargin{1};
                    case 'SMASH.SignalAnalysis.ShortTime'   
                        object=varargin{1};
                        return
                end
                try
                    object.Measurement=SMASH.SignalAnalysis.Signal(varargin{:});
                catch                    
                end
            else
                object.Measurement=SMASH.SignalAnalysis.Signal(varargin{:});
            end
            object.Measurement=regrid(object.Measurement);                
            object.Measurement.GraphicOptions.Title='ShortTime object';
            object.Measurement.GridLabel='Time';
            object.Measurement.DataLabel='Signal';
            object=partition(object,'Blocks',[10 0]);
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
    %% setters
    methods
        function object=set.Measurement(object,value)
            assert(isa(value,'SMASH.SignalAnalysis.Signal'),...
                'ERROR: invalid Measurement value');
            object.Measurement=value;
        end
        function object=set.Name(object,value)
            assert(ischar(value),'ERROR: invalid name');
            object.Name=value;
        end        
    end
end