% Symbol plot class
%
% This class supports symbol plots, where a modest number of marker
% points are displayed with an optional connecting line.  Unlike standard
% MATLAB lines, which have a limited set of markers, these plots support
% user-defined markers based on any available text font.  For example,
% exotic characters can be drawn from the Wingdings and Webdings fonts.
% Markers may indicate specific points of interest or help visually
% distingush curves when color and/or line style are insufficient.
%
% Symbol plot objects are constructed from a two-column data array.
%    object=SymbolPlot(data);
% By default, the symbol plot is rendered in the current axes.  A specific
% graphic target can also be indicated 
%    SymbolPlot(parent,data);
%
% See also SMASH.Graphics.PlotTools
%
classdef SymbolPlot < SMASH.Developer.SimpleHandle   
    %%
    properties (SetAccess=protected)
        Color = 'k'% Color Symbol/line color
        SymbolFont = get(groot,'FixedWidthFontName') % SymbolFont Font used for new symbols
    end
    %%    
    properties (SetAccess=protected)
        SymbolData % SymbolData Two-columm [x y] data for symbol locations 
        Symbol % Symbol Structure array of defined symbols
        LineData % LineData Two-column [x y] data for the connecting line
    end

    properties (SetAccess=protected, Hidden=true)
        Parent % Parent Graphical object parent
        Points % Points Graphic objects for marker points
        Line   % Line   Graphic object for connecting line
    end
    %%
    methods (Hidden=true)
        function object=SymbolPlot(varargin)           
            % manage input
            parent=[];
            switch nargin()
                case 0
                    error('ERROR: no data specified');
                case 1
                    data=varargin{1};                   
                case 2
                    parent=varargin{1};
                    data=varargin{2};
                otherwise
                    error('ERROR: too many input arguments');

            end
            % verify parent
            if isempty(parent)
                parent=gca();
                box on;
            else
                assert(ishandle(parent),'ERROR: invalid graphic parent');
                temp=ancestor(parent,'axes');
                if isempty(temp)
                    parent=ancestor(parent,'figure');
                    parent=gca(parent);
                else
                    parent=temp;
                end               
            end
            % generate graphics
            object.Parent=parent;
            repair(object);
            removeSymbol(object);            
            setSymbolData(object,data);                                              
        end        
    end
    methods (Static=true)
        varargout=showExample(varargin)
    end
end