% DataStack Data stack class
%
% This *abstract* class manages named data stacks.  Data values (any MATLAB
% variable) pushed onto the stack are popped off in reverse order.
%
% See also SMASH.General
%

%
% created November 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
classdef (Abstract) DataStack
    methods (Static=true)
        push(name,value)
        value=pop(name,value)
        list=probe(name)
        delete(varargin)
    end
    methods (Hidden=true)
        function object=DataStack(varargin)
        end
    end
end