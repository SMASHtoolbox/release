% UNDER CONTRUCTION
%
% This classes manages *long* signals, i.e. data that is too large to fit
% in physical memory.  The goal is to mix features from the Signal and
% SignalGroup classes with capabilities similar to MATLAB's datastore
% class...
%
%    object=LongSignal(file); % HDF5 file (restrictions!)
%


classdef LongSignal < handle
    %%
    properties (SetAccess=protected)
        File % Signal file (*.h5)
    end
    %%       
    properties (SetAccess=protected, Dependent=true)
        NumberPoints  % Number of signal points
        NumberSignals % Number of signal channels
    end
    methods
        function value=get.NumberPoints(object)   
            list=h5info(object.File);
            value=list.Datasets.Dataspace.Size;
            value=value(1);
        end
        function value=get.NumberSignals(object)
            list=h5info(object.File);
            value=list.Datasets.Dataspace.Size;
            value=value(2);
        end
    end
    %%
    properties (SetAccess=protected, Dependent=true)
        Start % Grid start (numeric scalar) 
        Stop % Grid stop value (numeric scalar) 
        Increment % Grid increment (numeric scalar) 
    end
    methods
        function value=get.Start(object)
            [flag,data]=verifyFile(object);
            assert(flag);
            value=data.Start;
        end
        function value=get.Stop(object)
            [flag,data]=verifyFile(object);
            assert(flag);
            value=data.Stop;
        end
        function value=get.Increment(object)
            [flag,data]=verifyFile(object);
            assert(flag);
            value=data.Increment;
        end
    end
    %%
    properties (SetAccess=protected)
        % Parition Analyisis partition settings
        %
        % This *protected* property contains a structure of partition settings
        % (points, duration, etc.).  Changes can only be made via the
        % partition method.
        %
        % See also partition
        Partition
    end
    %% constructor
    methods (Hidden=true)
        function object=LongSignal(file)
            % manage input
            assert(nargin > 0,'ERROR: no data file specified');
            object.File=file;
            assert(verifyFile(object),'ERROR: invalid data file');                       
        end
    end
    %%
    methods (Static=true)
        varargout=convertData(varargin)
    end
    %% hide unused methods for clarity
    methods (Hidden=true)
        varargout=addlistener(vararagin)
        varargout=delete(varargin)
        varargout=eq(vararagin)
        varargout=findobj(varargin)
        varagout=findprop(varargin)
        varargout=ge(varargin)
        varargout=gt(varargin)
        varargout=le(varargin)
        varargout=listener(varargin)
        varargout=lt(varargin)
        varargout=ne(varargin)
        varargout=notify(varargin)
    end
end