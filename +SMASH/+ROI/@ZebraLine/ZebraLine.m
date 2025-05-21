% This class creates line pairs with alternating color for enhanced
% visibility.  Creating a ZebraLine object:
%    object=ZebraLine(); % use current axes
%    object=ZebraLine(target); % use target axes
% generates a dashed foreground line on top of a solid background line.
% These lines are controlled through the object's properties.  For example:
%    object.Data=[0 0; 1 1];
% sets the (x,y) data values to (0,0) and (1,1).% 
%<a href="matlab:SMASH.System.showExample('SimpleExample','+SMASH/+ROI/@ZebraLine')">Simple example</a>
%
% The color, line width, and marker size of ZebraLines can be modified
% through a context menu.  To access this menu, right-click on any
% ZebraLine displayed in a MATLAB figure.  This menu can be disabled by
% passing a second input argument.
%    object=ZebraLine(target,'-fixed');
%
% See also SMASH.ROI
%

%
% created February 19, 2018 by Daniel Dolan (Sandia National Laboratories)
%
classdef ZebraLine < handle
    properties (SetAccess=protected, Hidden=true)
        Handle
    end
    properties (Dependent=true)
        Data % Data table ([x y] or [x y z])
    end
    properties (Dependent=true)        
        Color % RGB or text color setting for the dashed line
    end
    properties (SetAccess=protected)
        ConjugateColor % Background line color (read only)
    end
    properties (Dependent=true)
        MarkerSize % Marker size in points (0 means invisible) 
        LineWidth  % Line width in points (0 means invisible)
        Visible % Line/marker visibility
    end
    methods (Hidden=true)
        function object=ZebraLine(parent,fixed) 
            % manage input
            if (nargin < 1) || isempty(parent)
                parent=gca;                        
            else
                assert(isscalar(parent) && ishandle(parent) && ...
                    strcmpi(parent.Type,'axes'),'ERROR: invalid parent axes');
            end
            if (nargin < 2) || isempty(fixed) || strcmpi(fixed,'-notfixed')
                fixed=false;
            elseif strcmpi(fixed,'-fixed')
                fixed=true;
            else
                assert(isscalar(fixed) &&  islogical(fixed),...
                    'ERROR: invalid fixed option');               
            end
            % create line pair
            h(1)=line('Parent',parent,'XData',[],'YData',[]);
            h(2)=line('Parent',parent','XData',[],'YData',[]);
            h(1).LineStyle='-';            
            h(2).LineStyle='--';
            %
            object.Handle=h;
            object.Color=[1 1 1];
            object.LineWidth=2;
            object.MarkerSize=10;
            set(h,'DeleteFcn',@deleteLine)
            function deleteLine(varargin)
                delete(object);
            end
            if ~fixed
                set(h,'UIContextMenu',defineContextMenu(object));
            end
        end
        function delete(object)
            for n=1:2
                if ishandle(object.Handle(n))
                    delete(object.Handle(n));
                end
            end            
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
    %% getters
    methods 
        function value=get.Data(object)
            x=object.Handle(1).XData;
            y=object.Handle(1).YData;
            z=object.Handle(1).ZData;
            N=[numel(x) numel(y) numel(z)];
            value=nan(max(N),3);
            value(1:N(1),1)=x(:);
            value(1:N(2),2)=y(:);
            value(1:N(3),3)=z(:);
            drop=all(isnan(value),1);
            value=value(:,~drop);
        end        
        function value=get.Color(object)
            value=object.Handle(2).Color;
        end        
        function value=get.MarkerSize(object)
            if strcmpi(object.Handle(2).Marker,'none')
                value=0;
            else
                value=object.Handle(2).MarkerSize;
            end            
        end
        function value=get.LineWidth(object)
            if strcmpi(object.Handle(1).LineStyle,'none')
                value=0;
            else
                value=object.Handle(1).LineWidth;
            end
        end
        function value=get.Visible(object)
            value=object.Handle(1).Visible;
        end
    end
    %% setters
    methods
        function set.Data(object,value)
            assert(ismatrix(value) && isnumeric(value),...
                'ERROR: invalid data table');
            switch size(value,2)
                case 2
                    z=[];
                case 3
                    z=value(:,3);
                otherwise
                    error('ERROR: invalid data table');
            end
            x=value(:,1);
            y=value(:,2);
            for k=1:2
                object.Handle(k).XData=x;
                object.Handle(k).YData=y;
                object.Handle(k).ZData=z;
            end
            
        end        
        function set.Color(object,value)
            try
                object.Handle(2).Color=value;
            catch
                error('ERROR: invalid color');
            end
            value=object.Handle(2).Color;            
            object.ConjugateColor=abs(1-value);
            object.Handle(2).MarkerFaceColor=value;
            object.Handle(2).MarkerEdgeColor=object.ConjugateColor;
            object.Handle(1).Color=object.ConjugateColor;
            %             object.Handle(1).MarkerFaceColor=object.ConjugateColor;
            %             object.Handle(1).MarkerEdgeColor=object.ConjugateColor;
        end       
        function set.MarkerSize(object,value)
            try
                object.Handle(2).MarkerSize=value;
                object.Handle(2).Marker='o';
            catch
                if isnumeric(value) && isscalar(value) && (value == 0)
                    object.Handle(2).Marker='none';                    
                else
                    error('ERROR: invalid marker size');
                end
            end
        end
        function set.LineWidth(object,value)            
            try
                object.Handle(1).LineWidth=value;
                object.Handle(1).LineStyle='-';
                object.Handle(2).LineWidth=value;
                object.Handle(2).LineStyle='--';
            catch
                if isnumeric(value) && isscalar(value) && (value == 0)
                    object.Handle(1).LineStyle='none';
                    object.Handle(2).LineStyle='none';
                else
                    error('ERROR: invalid line width');
                end
            end           
        end
        function set.Visible(object,value)
            try
                object.Handle(1).Visible=value;
            catch
                error('ERROR: visible must be ''on'' or ''off''');
            end
            object.Handle(2).Visible=value;
        end
    end    

    
end