% This class creates lines with alternating color.  This effect is created
% by plotting a foreground line above of background line of a difference
% color.  The background line is solid while the foreground line is broken
% (dash, dot, or dash-dot), resulting a periodic color variation.
% Alternating colors are helpful for lines drawn above a background
% image--at least one of the colors should be discernable at every
% location.
%
% AlternatingLine objects are created in a similar fashion as standard
% lines:
%     >> h=AlternatingLine(x,y);
%     >> h=AlternatingLine(name1,value1,...);
% with a reduced set of properties.  Properties can be set at object
% creation (as shown above) or changed for an existing object.
%     >> set(h,'ForegroundColor','red'); % change foreground line color
%     >> h.ForeGroundColor='red'; % same result as above
% 
% See also Graphics
%

%
% created December 10, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef AlternatingLine < hgsetget
    %%
    properties
        Parent % Parent object (usually an axes)
        XData  % X data
        YData  % Y data
        ForegroundColor = 'black' % Foreground line color
        ForegroundStyle = '--' % Foreground line style
        BackgroundColor = 'white' % Background line color
        LineWidth = 0.5 % Foreground/background line width
        Visible = 'on' % Object visible ('on' or 'off')
    end
    properties (SetAccess=protected)
        Group % Handle graphic group (contains foreground/background lines)
    end
    %%
    methods (Hidden=true)
        function object=AlternatingLine(varargin)
            warning('This class is obsolote.  Use the ZebraLine class instead');
            % handle input
            if (nargin>=2) && isnumeric(varargin{1}) && isnumeric(varargin{2})
                x=varargin{1};
                y=varargin{2};
                varargin=varargin(3:end);
                varargin{end+1}='XData';
                varargin{end+1}=x;
                varargin{end+1}='YData';
                varargin{end+1}=y;
            end
            Narg=numel(varargin);
            assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
            parent=[];
            for n=1:2:Narg
                name=varargin{n};
                assert(isprop(object,name),'ERROR: invalid property name');
                value=varargin{n+1};
                object.(name)=value;
                if strcmpi(name,'parent')
                    parent=value;
                end
            end
            if isempty(object.Parent)
                object.Parent=gca;
            end
            % create graphics
            object.Group=hggroup('Parent',parent,'Visible','off');
            setappdata(object.Group,'SourceObject',object); % prevent delete on workspace clear
            line('Parent',object.Group,'Tag','Background');
            line('Parent',object.Group,'Tag','Foreground');
            update(object);
        end
        varargout=update(varargin);
        varargout=addlistener(varargin);
        varargout=eq(varargin);
        varargout=findobj(varargin);
        %varargout=findprop(varargin);
        varargout=ge(varargin);
        varargout=getdisp(varargin);
        varargout=gt(varargin);
        varargout=le(varargin);
        varargout=lt(varargin);
        varargout=ne(varargin);
        varargout=notify(varargin);
        varargout=setdisp(varargin);
    end
    methods
        function delete(object)
            try
                delete(object.Group);
            catch
            end
        end
    end
    %%
    methods
        function set.Parent(object,value)
            assert(ishandle(value),'ERROR: invalid Parent value');
            object.Parent=value;
            update(object)
        end
        function set.XData(object,value)
            assert(isnumeric(value),'ERROR: invalid XData value');
            object.XData=value;
            update(object);
        end
        function set.YData(object,value)
            assert(isnumeric(value),'ERROR: invalid YData value');
            object.YData=value;
            update(object);
        end
        function set.ForegroundColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.ForegroundColor=value;
            update(object);
        end
        function set.ForegroundStyle(object,value)
            switch value
                case {'--',':','-.'}
                    object.ForegroundStyle=value;
                otherwise
                    error('ERROR: invalid ForegroundStyle value');
            end
            update(object);
        end
        function set.BackgroundColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.BackgroundColor=value;
            update(object);
        end
        function set.LineWidth(object,value)
            assert(isnumeric(value) & isscalar(value) & value>0,...
                'ERROR: invalid line width');
            object.LineWidth=value;
            update(object);
        end
        function set.Visible(object,value)
            assert(ischar(value),'ERROR: invalid Visible value');
            value=lower(value);
            switch value
                case {'on','off'}
                    object.Visible=value;
                otherwise
                    error('ERROR: invalid Visible value');
            end
            update(object);
        end
    end
end