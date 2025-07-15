% This class defines core properties and methods for objects that store
% data.  The class is meant primarily as a superclass, but can be called
% directly.  The Signal and Image classes (located in SMASH.SignalAnalysis
% and SMASH.ImageAnalysis, respectively) are based on this class.
%
% See also SMASH, SMASH.General.GraphicOptions
%

%
% created November 14, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised December 9, 2014 by Daniel Dolan
%   -converted plot options from separate properties to a single class
classdef DataClass
    
    %% properties
    properties (SetAccess=protected)
        Data % Dependent array
        Source % Data source description
    end
    properties (SetAccess=protected,Hidden=true)
        ObjectHistory = {} % History of methods applied to object
    end
    properties (Hidden=true)
        ConcealedProperties = {}; % Properties concealed from standard display
        ConcealedMethods = {}; % Methods concealed from standard display
    end
    properties
        DataLabel = 'Data' % Dependent axes label
        Name = 'DataClass object' % Object name
        Comments = '' % Object comments
    end
    properties
        Precision='double' % Data format (double or single)
    end
    properties
        GraphicOptions % Graphic options
    end
    %% hidden methods
    methods (Hidden=true)
        function [object,data]=DataClass(varargin)                        
            if (nargin==0) || isFileName(object,varargin{1})
                data=SMASH.FileAccess.readFile(varargin{:});                                
                if isstruct(data)
                    object=import(object,data);
                elseif strcmp(class(object),class(data))
                    object=data;
                    object.Source='Restored object';
                else
                    error('ERROR: cannot convert from %s to %s',...
                        class(data),class(object));
                end
            elseif (nargin==1) && isstruct(varargin{1})
                object=restore(object,varargin{1});
                object.Source='Restored object';            
            else
                object=create(object,varargin{:});
                object.Source='Numeric input';
            end
            object.Precision=object.Precision; % enforce variable precision
            if isempty(object.GraphicOptions)
                object.GraphicOptions=SMASH.General.GraphicOptions;
            end
        end
        varargout=concealMethod(varargin);
        varargout=concealProperty(varargin);
        %varargout=disp(varargin);
        varargout=doc(varargin);
        varargout=help(varargin);
        varargout=revealMethod(varargin);
        varargout=revealProperty(varargin);
        varargout=updateHistory(varargin);
        varargout=store(varargout);
    end
    %% protected methods
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);
        varargout=import(varargin);        
    end
    methods (Static=true, Hidden=true)
        varargout=restore(varargin);
    end
    %% property setters
    methods
        function object=set.DataLabel(object,value)
            if ischar(value) || iscell(value)
                object.DataLabel=value;
            else
                error('ERROR: invalid DataLabel setting');
            end
        end
        function object=set.Name(object,value)
            if ischar(value)
                object.Name=value;
            else
                error('ERROR: invalid Name setting');
            end
        end
        function object=set.Comments(object,value)
            if ischar(value)
                object.Comments=value;
            else
                error('ERROR: invalid Comments setting');
            end
        end
        function object=set.Precision(object,value)
            % handle input
            switch value
                case {'single','double'}
                    object.Precision=value;
                otherwise
                    error('ERROR: %s is an invalid Precision',value);
            end
            % apply setting to all numeric entries
            name=properties(object);
            for n=1:numel(name)
                if isnumeric(object.(name{n}))
                    switch value
                        case 'double'
                            object.(name{n})=double(object.(name{n}));
                        case 'single'
                            object.(name{n})=single(object.(name{n}));
                    end
                end
            end
        end
        function object=set.GraphicOptions(object,value)
            assert(isempty(value) ...
                || isa(value,'SMASH.General.GraphicOptions'),...
                'ERROR: invalid GraphicOptions value');
            object.GraphicOptions=value;
        end
    end
    %% overloaded operators
    methods (Hidden=true)
        function object=uplus(object)
            object=updateHistory(object);
        end
        function object=uminus(object)
            object.Data=-object.Data;
            object=updateHistory(object);
        end
        function object=plus(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A+B;
            object=updateHistory(object);
        end
        function object=minus(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A-B;
            object=updateHistory(object);
        end
        function object=times(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A.*B;
            object=updateHistory(object);
        end
        function object=mtimes(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A.*B;
            object=updateHistory(object);
        end
        function object=rdivide(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A./B;
            object=updateHistory(object);
        end
        function object=mrdivide(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A./B;
            object=updateHistory(object);
        end
        function object=power(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A.^B;
            object=updateHistory(object);
        end
        function object=mpower(A,B)
            [object,A,B]=prepare(A,B);
            object.Data=A.^B;
            object=updateHistory(object);
        end
    end
    
end

%% helper functions

% This function prepares variables from the left (A) and right (B) side of
% an operator
function [object,A,B]=prepare(A,B)

classname='SMASH.General.DataClass';
if isa(A,classname) && isa(B,classname)
    object=A;
    A=A.Data;
    B=B.Data;
elseif isnumeric(A)
    object=B;
    B=B.Data;
    A=extend(A,B);
elseif isnumeric(B)
    object=A;
    A=A.Data;
    B=extend(B,A);
else
    error('ERROR: invalid operation')
end

end

% This function extends an array to match the size of a target array.
% Extension is performed when necessary.  For example, scalars do not need
% to be extended because MATLAB automatically manges their use with arrays.
% Extension is only possible when the array does not have more dimensions
% than the target.  Along each dimesion, the array must either have a size
% of 1 or match the target size.
function array=extend(array,target)

if isscalar(array) || all(size(array)==size(target))
    return
end

M=ndims(target);
if ndims(array)>M
    error('ERROR: incompatible array dimensions');
end
for m=1:M
    if size(array,m)==size(target,m)
        continue
    elseif size(array,m)>1
        error('ERROR: incompatible array dimensions');
    end
    index=ones(1,M);
    index(m)=size(target,m);
    array=repmat(array,index);
end


end