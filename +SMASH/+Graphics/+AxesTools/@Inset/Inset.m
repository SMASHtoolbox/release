% This class creates and manages axes insets, which are useful for
% highlighting plot details.  Insets are generated from a source axes.
%    object=Inset(haxes);
% The inset axes is drawn over the source axes, and inset boundaries are
% marked with a rectangle.  
%
% Inset bounds and axes location are controlled through object properties.
% For example:
%    object.Position=[0.10 0.50 0.50 0.40];
% places the left corner of the inset axes at (10%, 50%) of the source
% axes; the inset axes spans 50% of the width and 40% of the height of the
% source axes.
%
% See also SMASH.Graphics.AxesTools
%


%
% created January 19, 2016 by Daniel Dolan (Sandia National Laboratories)
% massively revised January 25, 2018 by Daniel Dolan
%
classdef Inset < handle
    %%
    properties (SetAccess = protected)
        Source % Source axes handle
        Handle % Inset axes handle
        Rectangle % Inset rectangle handle
    end
    properties (Dependent=true)
        XBound % Horizontal inset bounds
        YBound % Vertical inset bounds
        Position % Inset axes position (relative to the source axes)
    end   
    %%
    methods (Hidden=true)
        function object=Inset(source)
            % manage input
            if nargin < 2
                source=gca;
            else
                assert(ishandle(source) && strcmpi(source.Type,'axes'),...
                    'ERROR: invalid source handle');
            end          
            object.Source=source;
            % create inset axes
            xb=xlim(object.Source);            
            yb=ylim(object.Source);
            L=[diff(xb) diff(yb)]/5;
            xb(2)=xb(1)+L(1);
            yb(2)=yb(1)+L(2);
            fig=get(object.Source,'Parent');
            object.Handle=copyobj(source,fig);
            xlim(object.Handle,xb);
            ylim(object.Handle,yb);
            xlabel(object.Handle,'');
            ylabel(object.Handle,'');
            title(object.Handle,'');
            pos=getpixelposition(source);
            pos(1:2)=pos(1:2)+pos(3:4)*0.75;
            pos(3:4)=pos(3:4)*0.25;
            setpixelposition(object.Handle,pos);                 
            % create inset rectangle                        
            object.Rectangle=rectangle('Parent',object.Source,...
                'LineStyle','--','LineWidth',2,...
                'Position',[xb(1) yb(1) L]);            
            % delete functions
            set(object.Rectangle,'DeleteFcn',@deleteObject);
            set(object.Handle,'DeleteFcn',@deleteObject);
            function deleteObject(varargin)
                delete(object);
            end
        end
        function delete(object)            
            if ishandle(object.Handle)
                delete(object.Handle);
            end            
            if ishandle(object.Rectangle)
                delete(object.Rectangle)
            end            
        end
    end
    %% hide handle class methods from casual users
    methods (Hidden=true)
        varargout=addlistener(varargin);
        varagout=eq(varargin);
        varargout=findobj(varargin);
        varargout=findprop(varargin);
        varagout=ge(varargin);
        varagout=gt(varargin);
        %varagout=isvalid(varargin);
        varagout=le(varargin);
        varargout=listener(varargin);
        varagout=lt(varargin);
        varagout=ne(varargin);
        varagout=notify(varargin);
    end
    %% getters
    methods
        function value=get.XBound(object)
            value=xlim(object.Handle);           
        end
        function value=get.YBound(object)
            value=ylim(object.Handle);
        end
        function value=get.Position(object)
            srcpos=getpixelposition(object.Source);
            pos=getpixelposition(object.Handle);
            value(1)=(pos(1)-srcpos(1))/srcpos(3);
            value(2)=(pos(2)-srcpos(2))/srcpos(4);
            value(3)=pos(3)/srcpos(3);
            value(4)=pos(4)/srcpos(4);
        end
    end
    %% setters
    methods
        function set.XBound(object,value)
            try
                xlim(object.Handle,value);
            catch
                error('ERROR: invalid horizontal bound');
            end
            pos=get(object.Rectangle,'Position');
            pos(1)=value(1);
            pos(3)=diff(value);
            set(object.Rectangle,'Position',pos);
        end
        function set.YBound(object,value)
           try
                ylim(object.Handle,value);
            catch
                error('ERROR: invalid vertical bound');
            end
            pos=get(object.Rectangle,'Position');
            pos(2)=value(1);
            pos(4)=diff(value);
            set(object.Rectangle,'Position',pos);
        end
        function set.Position(object,value)
            assert(isnumeric(value) && numel(value)==4 && all(value(3:4) > 0),...
                'ERROR: invalid position');
            srcpos=getpixelposition(object.Source);
            pos(1)=srcpos(1)+value(1)*srcpos(3);
            pos(2)=srcpos(2)+value(2)*srcpos(4);
            pos(3)=srcpos(3)*value(3);
            pos(4)=srcpos(4)*value(4);
            setpixelposition(object.Handle,pos);
        end
    end
end