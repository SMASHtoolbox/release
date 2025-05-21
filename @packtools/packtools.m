% This class manages access to package functions and classes.  Tools
% provided by the class include: relative calls, controlled imports, and
% searching.
%
% To illustrate how these tools are useful, consider the following package
% hierarchy.
%    +MainPackage/
%       MainFuncA.m
%       MainFuncB.m
%       +SubPackage1/
%          SubFuncA.m
%          SubFuncB.m
%       +SubPackage2/
%          SubFuncC.m
%          SubFuncD.m
% Explicit function calls:
%    MainPackage.MainFuncA();
% assume a fixed package hierarchy. Problems arise when the package
% hiearchy is changed or under development. For example, the author of
% "SubFuncA" may have known that the function would be in a package, but
% not in a subpackage.  Calls from between functions within the same
% package and calls to sub-package functions need manual revision whenever
% the package hierarchy changes.
%
% Imported function calls:
%    import MainPackage.SubPackage1.*
%    SubFuncA();
% can reduce but do not eliminate the need for revisions during package
% reorganization.  Standard imports also have potential side effects: name
% clashes with existing functions are *not* reported and can lead to
% unexpected results.
%

%
% created May 14, 2017 by Daniel Dolan
%
classdef (Abstract) packtools
    %%
    methods (Hidden=true)
        function object=packtools(varargin)           
        end
    end
    %%
    methods (Static=true)
        varargout=call(varargin)        
        varargout=import(varargin)
        varargout=search(varargin)
    end
    methods (Static=true, Hidden=true)
        varargout=namespace(varargin)
        varargout=decompose(varargin)
    end
end