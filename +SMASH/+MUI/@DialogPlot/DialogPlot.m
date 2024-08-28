% The class generates a custom dialog panel alongside a panel of plots. The
% dialog panel may contain multiple controls of different types, as in the
% Dialog class.  The size of this panel is determined by the controls
% inside, which set a minimum size for the overal figure.  To the right of
% the control panel is a resizeable plot panel.  This panel starts with one
% resizable axes; additional axes can be added manually or through MATLAB's
% subplot command.
%
% Start by creating an object:
%    dp=DialogPlot();
% Use the "addblock" method to place items in the control panel.
%
% See also SMASH.MUI.Dialog, subplot
%

%
% created April 2, 2017 by Daniel Dolan (Sandia National Laboratories)
%
classdef DialogPlot < handle
    properties (Dependent=true)
        Name % Figure name
    end
    properties
        Hidden = false % Visibility setting
    end
    properties (SetAccess=protected)
        Locked = false % Dialog locked
        Figure % Figure handle
        ControlPanel % Control panel handle
        PlotPanel % Plot panel handle
    end
    properties (SetAccess=protected, Dependent=true)
        Axes % Axes handle(s)
        Control % Control handles
    end
    properties (SetAccess=protected,Hidden=true)
        PrivateName = 'Dialog plot'
        DialogBox
    end
    %%
    methods (Hidden=true)
        function object=DialogPlot(varargin)
            object=create(object,varargin{:});
        end
    end
    methods (Access=protected, Hidden=true)
        varargout=create(varargin);
    end
    methods (Static=true, Hidden=true)
        varagout=restore(varargin)
    end
    %% setters and getters
    methods
        function set.Name(object,value)
            assert(ischar(value),'ERROR: invalid name specified');
            object.PrivateName=value;
            set(object.Figure,'Name',value);
        end
        function value=get.Name(object)
            value=object.PrivateName;
        end
        function value=get.Axes(object)
            value=findall(object.PlotPanel,'Type','axes');
        end
        function value=get.Control(object)
            value=get(object.ControlPanel,'Children');
        end
    end
    %% hide class methods from casual users
    methods (Hidden=true)
        %varargout=addlistener(varargin);
        varagout=eq(varargin);
        varargout=findobj(varargin);
        varargout=findprop(varargin);
        varagout=ge(varargin);
        varagout=gt(varargin);
        %varagout=isvalid(varargin);
        varagout=le(varargin);
        varagout=lt(varargin);
        varagout=ne(varargin);
        varagout=notify(varargin);
    end
end