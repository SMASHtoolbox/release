% This class manages the format of MATLAB scripts and their inclusion into
% the SMASH toolbox.  Refer to the static methods below.

%
% created January 8, 2018 by Daniel Dolan (Sandia National Laboratories)
%
classdef (Abstract) Script
    methods (Static=true)
        varargout=isScript(varargin)
        varargout=convert(varargin)
        varargout=insertExample(varargin)
        varargout=extractExample(varargin)      
        varargout=showExample(varargin);
    end
    
end