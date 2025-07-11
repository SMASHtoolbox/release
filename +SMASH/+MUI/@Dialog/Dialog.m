% Dialog class
%
% This class provides for the construction of custom dialog boxes. These
% dialogs can contain multiple controls of different types, allowing users
% to input different types of information.  The class takes care of the
% creation and placement of controls inside the dialog so that the creator
% can focus on what the dialog box should do rather than how it is built.
%
% Start by creating a custom dialog object.
%    >> object=Dialog();
% When this command is executed, MATLAB creates a small, empty dialog box
% named 'Custom dialog' that is linked to the variable 'object'.  Deleting
% the object:
%    >> delete(object);
% causes the dialog box to deleted immediately.  Closing the dialog box
% automatically deletes the object as well: the variable will still exist
% in memory but is no longer functional.
%
% Controls in a custom dialog are added in "blocks", each of which is
% stacked vertically in the dialog.  For example:
%    >> addblock(object,'edit');
%    >> h=addblock(object,'button',' Apply ');
% creates an edit box with a push button underneath it, sizing the dialog
% box automatically so that all controls fit neatly inside.  A complete
% discussion of control blocks is contained in the help entry for the
% "addblock" method.  Callbacks can be added to make the dialog useful.
%    >> set(h,'Callback',@my_function);
% Additional control and access to the dialog box is provided by the
% "locate" and "probe" methods, each of which is documented separately.
%
% Some properties of a custom dialog object can be changed directly.  For
% example:
%    >> object.Name='My dialog box'; % change dialog name
% The 'Locked', 'Modal', and 'Hidden' properties behave in similar manner.
% The 'Handle property stores the graphic handle of the dialog box (MATLAB
% figure) for customization purposes.
%    >> set(object.Handle,'Color','w'); % make background white
% Extensive use of this property is discouraged since much of the figure
% layout is controlled within the class.  The 'Controls' property is an
% array of graphic handles for every control in the dialog.  This property
% is empty at object creation and only changes when the 'addblock' method
% is used.
%
% Direct access of the handles contained in a custom dialog object is
% recommended for advanced users only.  The method 'addlistener' and events
% associated with the class should also be ignored by most users.  The
% method 'isvalid' can be used:
%    >> isvalid(object); % determine if dialog still exists
% but is generally unnecessary.
%
% See also SMASH.MUI, Figure, Line, addblock, locate, probe

% created August 2, 2013 by Daniel Dolan (Sandia National Laboratories)
% updated October 7, 2013 by Daniel Dolan
%    -revised documentation
classdef Dialog < handle
    %%
    properties
        Name = 'Custom dialog' % Title bar label
        Locked = false % Prohibit changes
        Modal = false % Prohibit access to other windows
        Hidden = false % Visibility setting
    end
    properties (SetAccess=private)
        Handle % Graphic handle
        Controls = [] % Control handles (uicontrol, uitab, axes objects)
        Boxes = [] % Box handles (axes objects)
    end
    properties (SetAccess=immutable,Hidden=true)
        FontName 
        FontUnits
        FontSize
        HorizontalMargin=0
        HorizontalGap=0
        VerticalMargin=0
        VerticalGap=0
    end
    properties (Access=private)
        MinimumFigureWidth=0
    end
    %%
    methods (Hidden=true)
        % object creator
        function object=Dialog(varargin)
            % process input
            if rem(nargin,2)==1
                error('ERROR: unmatched name/value pair');
            end
            for n=1:2:nargin
                name=varargin{n};
                value=varargin{n+1};
                try
                    object.(name)=value;
                catch
                    fprintf('Ignoring unrecogized name ''%s''\n',name);
                end
            end
            if isempty(object.FontName)
                object.FontName=get(0,'DefaultUIControlFontName');
            end
            if isempty(object.FontUnits)
                object.FontUnits=get(0,'DefaultUIControlFontUnits');
            end
            if isempty(object.FontSize)
                object.FontSize=get(0,'DefaultUIControlFontSize');               
            end            
            % create dialog and probe uicontrol size
            object.Handle=figure('Toolbar','none','MenuBar','none',...
                'NumberTitle','off','IntegerHandle','off',...
                'DockControls','off',...
                'Name',object.Name,'Units','pixels','Resize','off',...
                'DefaultUIControlUnits',object.FontUnits,...
                'DefaultUIControlFontName',object.FontName,...
                'DefaultUIControlFontUnits',object.FontUnits,...
                'DefaultUIControlFontSize',object.FontSize,...
                'DefaultUITableFontUnits',object.FontUnits,...
                'DefaultUITableFontName',object.FontName,...
                'DefaultUITableFontSize',object.FontSize);
            dummy=repmat('M',[1 numel(object.Name)+2]);
            h=local_uicontrol(object,'Style','text','String',dummy);
            set(h,'Units','pixels');
            extent=get(h,'Extent');
            delete(h);
            object.HorizontalMargin=ceil(extent(3)/numel(dummy));
            object.HorizontalGap=object.HorizontalMargin;
            object.VerticalMargin=ceil(extent(4)/2);
            object.VerticalGap=object.VerticalMargin;
            object.MinimumFigureWidth=max(object.MinimumFigureWidth,extent(3));
            position=get(object.Handle,'Position');
            position(3)=extent(3);
            position(4)=2*object.VerticalMargin;
            set(object.Handle,'Position',position,'UserData',object);
            % link object and dialog box
            addlistener(object,'ObjectBeingDestroyed',@closeDialog);
            function closeDialog(varargin)
                delete(object.Handle);
            end
            setappdata(object.Handle,'CleanupObject',...
                onCleanup(@deleteObject));
            function deleteObject(varargin)
                delete(object); %#ok<MOCUP>
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
    %% canned dialogs
    methods (Static=true)
        varargout=Message(varargin)
        varargout=SimpleQuestion(varargin)
        varargout=ComplexQuestion(varargin)
        varargout=Input(varargin)
        varargout=browseDrive(varargin)
        varargout=SimpleNotes(varargin)
    end
    %% utility methods
    methods
        function show(object)
            % Make Dialog visible and active
            %     >> show(object);
            figure(object.Handle);
        end
    end
    methods (Access=protected,Hidden=true)
        %%
        function pushup(obj,Nfreeze,shift)
            children=get(obj.Handle,'Children');
            if (nargin<2) || isempty(Nfreeze)
                Nfreeze=1;
            end
            if (nargin<3) || isempty(shift)
                shift=0;
                for n=1:Nfreeze
                    position=get(children(n),'Position');
                    shift=max(shift,position(4));
                end
            end
            for n=(Nfreeze+1):numel(children)
                switch get(children(n),'Type')
                    case 'uimenu'
                        continue
                end
                pos=get(children(n),'Position');
                pos(2)=pos(2)+shift;
                set(children(n),'Position',pos);
            end
        end
        %%
        function make_room(obj)
            h=get(obj.Handle,'Children');
            Lx=obj.MinimumFigureWidth;
            Ly=obj.VerticalMargin;
            for n=1:numel(h)
                switch get(h(n),'Type')
                    case {'uimenu' 'uicontextmenu'}
                        continue
                end
                pos=get(h(n),'Position');
                Lx=max(Lx,pos(1)+pos(3)+obj.HorizontalMargin);
                Ly=max(Ly,pos(2)+pos(4)+obj.VerticalMargin);
            end
            pos=get(obj.Handle,'Position');
            pos(3:4)=[Lx Ly];
            set(obj.Handle,'Position',pos,'Resize','off');
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
        function set.Locked(object,value)
            if islogical(value)
                object.Locked=value;
            else
                error('ERROR: setting must a logical value');
            end
        end
        function set.Modal(object,value)
            if islogical(value)
                object.Modal=value;
            else
                error('ERROR: setting must a logical value')
            end
            if object.Modal
                %object.Hidden=false;
                set(object.Handle,'WindowStyle','modal') %#ok<MCSUP>
            else
                set(object.Handle,'WindowStyle','normal') %#ok<MCSUP>
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
                set(object.Handle,'Visible','on'); %#ok<MCSUP>
                figure(object.Handle); %#ok<MCSUP>
            end
        end
    end
end