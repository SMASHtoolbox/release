% This class defines a finite-width bounding curve in two-dimensional
% space.  Two curve directions are supported.  Horizontal curves have
% monotonically increasing x-cordinates and vertical widths.  Vertical
% curves have monotically increasing y-coordinates and horizontal widths.
%
% BoudingCurve objects are typically created with a specified direction.
%     >> object=BoudingCurve('horizontal');
%     >> object=BoudingCurve('vertical');
% The default direction is 'horizontal', and this setting can be changed
% through the Direction property. 
%     >> object.Direction='vertical';
%     >> object.Direction='horizontal';
%
% The initial bounding curve is defined to be empty.  To override this
% behavior, a Nx3 table of curve points (location, center, width) can be
% passed at object creation.
%     >> object-BoudingCurve(direction,table);
% Class methods "define", "insert, and "remove" alter the bounding curve
% after object creation.
%
% See also SMASH.ROI
% 

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
% revised December 5, 2014 by Daniel Dolan
%   -added Label property to assist multiple region selection later on
%   -advanced options provided in select method
classdef BoundingCurve
    %%
    properties (SetAccess=protected)        
        Data % Boundary Data
    end
    properties
        Direction = 'horizontal'; % Independent axis ('horizontal' or 'vertical')
        DefaultWidth % Default boundary width
        Label = 'Boundary curve' % Text label
        ColumnLabel = {'x' 'y' 'width'} % Table column labels
        GraphicOptions % Graphic options
    end
    %%
    methods (Hidden=true)
        function object=BoundingCurve(varargin)           
            warning('This class is deprecated.  Use the Curve class instead');
            % handle input
            if nargin>=1
                object.Direction=varargin{1};
            end
            if nargin>=2
                object.Data=varargin{2};
            end                         
            if isempty(object.GraphicOptions)
                object.GraphicOptions=SMASH.General.GraphicOptions;
                object.GraphicOptions.LineWidth=2;
            end
        end
        varargout=disp(varargin);
    end
    %%
    methods (Static=true,Hidden=true)
        function object=restore(data)
            object=SMASH.ROI.BoundingCurve;
            name=fieldnames(data);
            for n=1:numel(name)
                if isprop(object,name{n})
                    object.(name{n})=data.(name{n});
                end
            end
        end
    end
    %% property setters
    methods
        function object=set.Direction(object,value)
            if strcmpi(value,'horizontal') || isempty(value)
                object.Direction='horizontal';
            elseif strcmpi(value,'vertical')
                object.Direction='vertical';
            else
                error('ERROR: invalid direction');
            end
        end
        function object=set.DefaultWidth(object,value)
            assert(SMASH.General.testNumber(value,'positive') & (value>0),...
                'ERROR: invalid DefaultWidth value');
            object.DefaultWidth=value;
        end
        function object=set.Label(object,value)
            assert(ischar(value),'ERROR: invalid label');
            object.Label=value;
        end
        function object=set.GraphicOptions(object,value)
            if isempty(value)
                object.GraphicOptions=SMASH.General.GraphicOptions;
            elseif isa(value,'SMASH.General.GraphicOptions') 
                object.GraphicOptions=value;
            else
                error('ERROR: invalid GraphicOptions value');
            end        
        end
        function object=Set.ColumnLabel(object,value)
            assert(iscellstr(value) && numel(value)==3,...
                'error: invalid ColumnLabel value');
            object.ColumnLabel=value;
        end
    end
end