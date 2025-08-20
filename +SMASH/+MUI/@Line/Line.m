% This class provides lines for manual user interfaces.  Line
% created by this class are similar to MATLAB's standard line objects, but
% a special context menu is provided.
%
%    >> object=Line(x,y);
%    >> object=Line(name,value,...);
%
% See also MUI, Figure, Dialog
%

% created August 3, 2013 by Daniel Dolan (Sandia National Laboratories)
% updated October 7, 2013 by Daniel Dolan
%    -revised documentation
classdef Line < handle
    %%
    properties (SetAccess=immutable)
        Handle
    end
    %%
    methods (Hidden=true)
        function object=Line(varargin)
            % create object and collect handles
            object.Handle=line(varargin{:});
            % create context menu to allow user to interactively change color
            cmenu=uicontextmenu();
            set(object.Handle,'UIContextMenu',cmenu);
            uimenu(cmenu,'Label','Line settings',...
                'Callback',{@appearance,object.Handle});   
            uimenu(cmenu,'Label','Export to (x,y) file','Tag','export',...
                'Callback',{@export,object.Handle});
            % link object and dialog box
            addlistener(object,'ObjectBeingDestroyed',@destroy);
            set(object.Handle,'DeleteFcn',@destroy);
            setappdata(object.Handle,'CustomLine',object);
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