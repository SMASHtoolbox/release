% Log Message logging class
%
% This class supports several types of message logging.  Messages can be
% simultaneously written to the command window, text files, and list box
% objects.  Log objects are created from a list indicating where messages
% are to be written.
%    object=Log(target1,target2,...);
% Valid targets include:
%    -'-stdout' and '-stderr' for the command window
%    -Text file names
%    -List box handles
% The default target, if none are specified, is '-stdout'.
%
% See also SMASH.System
%

%
% created October 21, 2018 by Daniel Dolan (Sandia National Laboratories)
%
classdef Log < handle
    properties (SetAccess=protected)
        Target % Log targets (cell array)
    end
    properties
        Warning = 'on' % Generate log warnings ('on' or 'off')       
    end
    methods (Hidden=true)
        function object=Log(varargin)
            reset(object,varargin{:});                      
        end
    end
    methods (Hidden=true)
        varargout=addlistener(varargin)
        varargout=eq(varargin)
        varargout=findprop(varargin)
        varargout=gt(varargin)
        varargout=le(varargin)
        varargout=lt(varargin)
        varargout=notify(varargin)
        varargout=findobj(varargin)
        varargout=ge(varargin)
        varargout=listener(varargin)
        varargout=ne(varargin)
    end
    methods (Access=protected, Hidden=true)
        varargout=generateWarning(varargin)
    end
    %% setters
    methods
        function set.Warning(object,value)
            if strcmpi(value,'on') || strcmpi(value,'off')
                object.Warning=lower(value);
            else
                error('ERROR: warning state must be ''on'' or ''off''');
            end
        end
        
    end
end