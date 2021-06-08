% This class stores and manages a set of options.  Each option is
% associated with a unique name that follows MATLAB variable name
% requirements (type "doc isvarname" for more information).  Option values
% can be numeric or character arrays; allowable values for each option can
% be specified.
% 
% Once an Options object is created:
%    >> object=Options(); % empty object created
% options can be added and removed using class methods.  Existing options
% can be read from (get), written to (get), or documented (describe).
%
% See also General, add, describe, get, remove, set
%

%
% created November 17, 2014 by Daniel Dolan (Sandia National Laboratory)
%
classdef Options
    %%
    properties (SetAccess=protected)
        Name = {}
        Value = {}
        Allowed = {}
        Description = {}
        DescriptionLock = {}
    end
    %%
    methods (Hidden=true)
        function object=Options(varargin)
            % nothing to do
        end
        varargout=disp(varargin)
        varargout=display(varargin);
    end
end