% DRS4 file class
%
% This *abstract* class supports text and binary files created by the DRS4 evaluation
% board (Paul Scherrer Institute).  Objects cannot be created from this
% class, but static methods allow DRS4 files to be probed and read.
%
% See also SMASH.FileAccess
%
classdef (Abstract) DRS4
    
    methods (Hidden=true)
        function object=DRS4(varargin)
        end
    end
    %%
    methods (Static=true, Hidden=true)
        varargout=select(varargin)
    end
    methods (Static=true)
        varargout=probe(varargin)
        varargout=read(varargin)
    end
end