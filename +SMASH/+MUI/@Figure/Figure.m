% Figure class
%
% This class creates custom figures for graphical interface production.
% Custom figures lack the standard menu and toolbars that MATLAB generally
% provides.  Instead, a custom toolbar is provided with the following
% features.
%   -Set current directory
%   -Export figure
%   -Zoom
%   -Pan
%   -Auto scale
%   -Manual scale
%   -Data cursor
%   -Region of interest statistics
%   -Data overlay
%   -Clone axes
%   -Image slice
%   -Toolbar help
%  By default, custom figures have non-integer handles with standard
%  visbility.
% 
% To create a custom figure, call the class with any input accepted by the
% the "figure" function.
%    >> object=Figure(...);
% The object created by the class has read-only properties ("Handle",
% "ToolBar", and "ToolButton") containing graphical handles for items in
% the figure.  Two writable properties are also provided.
%    >> object.Name="My figure"; % change figure name
%    >> object.Hidden=true; % make figure invisible
%    >> object.Hidden=false; % make figure visible
% The location of the figure can be controlled with the "locate" method.
%    >> locate(object,'center'); % center figure on screen
%    >> locate(object,'east',reference); % place figure on east side of a reference figure
% 
% Several of the custom figure toolbar items create new figures to display
% information.  Most of these figures are automatically destroyed when the
% custom figure is closed or deleted.  One exception to this rule is cloned
% figures, which become independent from the source figure after creation.
%
% See also MUI, Dialog, Line, locate

% created August 5, 2013 by Daniel Dolan (Sandia National Laboratories)
% updated October 7, 2013 by Daniel Dolan
%    -revised documentation
classdef Figure < handle
    %%
    properties
        Name = 'Custom figure' % Title bar label
        Hidden = false % Visibility setting
    end
    properties (SetAccess=private)
        Handle % Graphic handle
    end
    properties (SetAccess=private)
        ToolBar % Graphic handle
        ToolButton % Graphic handles
    end
    properties (Access=private)
        Pointer
        PointerShapeCData
        WindowButtonDownFcn
        WindowButtonMotionFcn
        WindowButtonUpFcn
        ButtonDownFcn
    end
    methods (Hidden=true)
        function object=Figure(varargin)
            % process input
            if rem(nargin,2)==1
                error('ERROR: unmatched name/value pair');
            end
            option=struct('Toolbar','none','MenuBar','none',...
                'DockControls','off','Units','pixels','Resize','on');                    
            for n=1:2:nargin
                name=varargin{n};               
                value=varargin{n+1};
                try
                    option=SMASH.General.matchStructure(option,name,value);
                catch
                    option.(name)=value;
                end
            end
            name=fieldnames(option);
            N=numel(name);
            temp=cell(1,2*N);
            for n=1:N
                temp{2*n-1}=name{n};
                temp{2*n}=option.(name{n});
            end
            fig=figure(temp{:});            
            % create figure and toolbar
            object.Handle=fig;
            object.ToolBar=uitoolbar('Parent',fig);
            object.Pointer=get(fig,'Pointer');            
            object.PointerShapeCData=get(fig,'PointerShapeCData');
            object.WindowButtonDownFcn=get(fig,'WindowButtonDownFcn');       
            object.WindowButtonMotionFcn=get(fig,'WindowButtonMotionFcn');
            object.WindowButtonUpFcn=get(fig,'WindowButtonUpFcn');
            object.ButtonDownFcn=get(fig,'ButtonDownFcn');
            directory(object,'create');
            export(object,'create');
            zoom(object,'create');  
            pan(object,'create');
            autoscale(object,'create');
            tightscale(object,'create');
            manualscale(object,'create');
            datacursor(object,'create');
            ROIstatistics(object,'create');
            overlay(object,'create');
            slice(object,'create');
            clone(object,'create');
            dump(object,'create');
            standard(object,'create');
            help(object,'create');       
            % link figure to dialog boxes generated from it
            uicontrol('Parent',object.Handle,'Visible','off',...
                'Tag','FigureObjectLink',...
                'UserData',object,'DeleteFcn',@destroy); % this handles figure delete and close!
            setappdata(fig,'FigureObject',object);
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
    %% hide local methods from casual users
    methods (Hidden=true)        
        autoscale(varargin);
        clone(varargin);
        datacursor(varargin);
        directory(varargin);
        export(varargin);
        help(varargin);
        manualscale(varargin);
        overlay(varargin);
        pan(varargin);
        ROIstatistics(varargin);
        slice(varargin);
        tightscale(varargin);
        zoom(varargin);
    end
    methods (Access=private)
        toggle(varargin);
        detoggle(varargin);
    end
    %% utility methods
    methods
        function show(object)
            % Make Figure visible and active
            %     >> show(object);
            figure(object.Handle);        
        end
    end
    %% set methods
    methods
        function set.Name(object,value)
            if ischar(value)
                set(object.Handle,'Name',value); %#ok<MCSUP>
                object.Name=value;
            else
                error('ERROR: invalid name specified');
            end
        end
        function set.Hidden(object,value)
            if islogical(value)
                object.Hidden=value;
            else
                error('ERROR: setting must a logical value')
            end
            if object.Hidden
                set(object.Handle,'Visible','off'); %#ok<MCSUP>
            else
                set(object.Handle,'Visible','on'); %#ok<MCSUP>o
                figure(object.Handle); %#ok<MCSUP>
            end
        end
    end
    
end