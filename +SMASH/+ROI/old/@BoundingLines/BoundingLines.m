% This class defines a pair of bounding lines in two-dimensional space.
% Horizontal lines define a minimum and maximum value for the vertical
% direction, while vertical lines define a minimum and maximum value for
% the horizontal direction.  Bounding values may be finite or infinite.
%
% BoundingLine objects are typically created with a specified direction.
%     >> object=BoundingLines('horizontal');
%     >> object=BoundingLines('vertical');
% The default direction is 'horizontal', and this setting can be changed
% through the Direction property. 
%     >> object.Direction='vertical';
%     >> object.Direction='horizontal';
%
% Bounding lines are initially placed at negative and positive infinity.
% Alternate boundaries can be specified at object creation:
%     >> object=BoundingLine(direction,[lower upper]);
% or with the "define" and "select" methods.
%
% See also SMASH.ROI
%

%
% created November 14, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef BoundingLines
    %%
    properties (SetAccess=protected)
        Direction % Boundary line direction ('horizontal' or 'vertical')
        Data = [-inf inf] % Boundary data (1x2 array)
    end
    properties
        PlotOptions = SMASH.General.GraphicOptions % Graphic options
    end
    %%
    methods (Hidden=true)
        function object=BoundingLines(direction,data)
            % handle input
            if (nargin<1) || isempty(direction) ...
                    || strcmpi(direction,'horizontal')
                object.Direction='horizontal';
            elseif strcmpi(direction,'vertical')
                object.Direction='vertical';
            else
                error('ERROR: invalid direction');
            end
            if nargin>=2
                object=define(object,data);
            end           
        end
        varargout=disp(varargin)
    end
    %%
    methods
        function object=set.Direction(object,value)
            assert(ischar(value),'ERROR: invalid direction');
            value=lower(value);
            switch value
                case {'horizontal','vertical'}
                    object.Direction=value;
                otherwise
                    error('ERROR: invalid direction');
            end
        end
    end
end