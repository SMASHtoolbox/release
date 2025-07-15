% This class provides programmatic control over the graphical pointer.
%    object=PointerControl();
% Pointer location can be accessed through the Location property.
%    current=object.Location;
%    object.Location=[x y]; 
% Locations are always specified in pixels.
%
% See also SMASH.Graphics.DisplayTools
% 

%
% created January 17, 2020 by Daniel Dolan (Sandia National Laboratories)
%
classdef PointerControl < handle
    %% 
    properties (Dependent=true)
        Location % Pointer location in pixels
    end
    methods
        function value=get.Location(object) %#ok<MANU>
            value=getCursorLocation();
        end
        function set.Location(object,value)
            assert(isnumeric(value),'ERROR: invalid location');
            if isscalar(value)
                value=repmat(value,[1 2]);
            else
                assert(numel(value) == 2,'ERROR: invalid location');
            end
            value(2)=object.MonitorPosition(1,4)-value(2);
            value=round(value);
            object.Robot.mouseMove(value(1),value(2));
        end
    end
    properties (SetAccess=protected)
        History = nan(0,2); % Location history
    end
    %%
    properties (SetAccess=protected, Hidden=true)
        Robot
        Button1
        MonitorPosition
    end  
    methods (Hidden=true)
        function object=PointerControl()
            object.Robot=java.awt.Robot();
            object.Button1=java.awt.event.InputEvent.getMaskForButton(1);
            object.MonitorPosition=get(groot,'MonitorPositions');                        
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