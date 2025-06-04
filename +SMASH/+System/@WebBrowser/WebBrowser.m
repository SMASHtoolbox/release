% WebBrowser Web browser control class
%
%
% This class provides advanced control over MATLAB's web browser.  Creating
% an object:
%    object=WebBrowser();
% displays the browser and scans all open tabs.
%
% The browser's position can be probed and changed through the Position
% property.
%    pos=object.Position; % pixel units, MATLAB convention
%    object.Position=[x0 y0 Lx Ly]; 
% Cardinal positions can also be specified.
%    object.Position='northeast';
%
% See also SMASH.System
%

%
% created April 20, 2018 by Daniel Dolan (Sandia National Laboratories)
%
classdef WebBrowser 
    properties (Dependent=true, Hidden=true)
        Master % Master pane
    end
    properties (Dependent=true)        
        Position % Browser position in pixels [x0 y0 Lx Ly] using MATLAB convention              
    end   
    properties (Dependent=true, SetAccess=protected)
        Tab % Browser tabs
        CurrentIndex % Current tab index
    end
    %%
    methods (Hidden=true)
        function object=WebBrowser()
            rehash(object);
        end
        varargout=clickItem(varargin);
        varargout=chooseIndex(varargin);
    end    
    %% getters
    methods
        function value=get.Master(~)
            report=getappdata(groot,'WebBrowser');
            value=report.Master;
        end
        function value=get.Position(object)
            master=object.Master;
            x0=master.getX();
            y0=master.getY();
            %
            temp=master.getSize();
            Lx=temp.getWidth();
            Ly=temp.getHeight();
            %
            pos=get(groot,'ScreenSize');
            y0=pos(4)-y0-Ly;
            value=[x0 y0 Lx Ly];
        end       
        function value=get.Tab(~)
            report=getappdata(groot,'WebBrowser');
            value=report.Tab;
        end
        function value=get.CurrentIndex(object)
            [~,browser]=web();
            for value=1:numel(object.Tab)
                if browser == object.Tab(value).Browser
                    return
                end
            end
            warning('No match');
        end
    end
    %% setters
    methods
        function object=set.Position(object,value)
            if isnumeric(value)
                switch numel(value)
                    case 2
                        pos=object.Position;
                        pos(1:2)=value;
                        value=pos;
                    case 4
                        % keep going
                    otherwise
                        error('ERROR: invalid position array');
                end
            elseif ischar(value)
                fig=figure('Visible','off','Units','pixels');
                CU=onCleanup(@() close(fig));
                fig.OuterPosition=object.Position;
                try
                    movegui(fig,value);
                catch
                    error('ERROR: invalid position name');
                end
                value=get(fig,'OuterPosition');
            else
                error('ERROR: invalid position');
            end
            
            % apply setting
            value=round(value);            
            pos=get(groot,'ScreenSize');
            x0=value(1);
            y0=pos(4)-value(2)-value(4);                        
            object.Master.setLocation(x0,y0);
            object.Master.setSize(value(3),value(4));
        end        
    end
    
end