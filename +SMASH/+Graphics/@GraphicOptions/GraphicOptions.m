% This class manages graphic options in various parts of the SMASH package
% (SignalAnalysis, ImageAnalysis, etc.).
%
% See also General
% 

%
% created December 10, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef GraphicOptions
    %%
    properties
        LineStyle = '-' % Line style
        LineColor = 'black' % Line color
        LineWidth = 0.5 % Line width [points]
        Marker = 'o' % Marker
        MarkerSize = 5 % Marker size [points]
        MarkerStyle = 'open' % Marker style ('open' or 'closed')
        Box = 'on' % Axes box ('on' or 'off')
        AspectRatio = 'auto' % Axes aspect ratio ('auto' or 'equal')
        AxesColor = 'white' % Axes color
        AxesLayer = 'top' % Axes layer
        XDir = 'normal' % x-axis direction ('normal' or 'reverse')
        YDir = 'normal' % y-axis direction ('normal' or 'reverse')
        Title = '' % Axes title
        PanelColor = get(0,'DefaultUIPanelBackgroundColor') % Uipanel color
        ColorMap = jet(64) % Figure color map; default is jet(64)
        FigureColor = get(0,'DefaultFigureColor') % Figure color
    end
    %% property setters
    methods (Hidden=true)
        function object=GraphicOptions(varargin)            
            % handle input
            assert(rem(nargin,2)==0,'ERROR: unmatched name/value pair');
            for n=1:2:nargin
                name=varargin{n};
                assert(isprop(object,name),'ERROR: invalid name');
                object.(name)=varargin{n+1};
            end
            %
            message{1}='This class is obsolete and will be removed in the future';
            message{2}='Use the SMASH.General.GraphicOptions class instead';
            warning('SMASH:obsolete','%s\n',message{:});
        end
    end
%% static methods
    methods (Static=true, Hidden=true)
        function object=restore(data)
            object=SMASH.General.GraphicOptions();
            name=fieldnames(data);
            for k=1:numel(name)
                if isprop(object,name{k})
                    object.(name{k})=data.(name{k});
                end
            end
        end
    end
    %% property setters
    methods
        function object=set.LineStyle(object,value)
            switch value
                case {'-','--','-.',':','none'}
                    object.LineStyle=value;
                otherwise
                    error('ERROR: invalid line style');
            end
        end
        function object=set.LineColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid color');
            object.LineColor=value;
        end
        function object=set.LineWidth(object,value)
            assert(isnumeric(value) & isscalar(value) & value>0,...
                'ERROR: invalid line width');
            object.LineWidth=value;
        end
        function object=set.Marker(object,value)
            switch value
                case {...
                        '+','o','*','.','x','s','sq','square','d','diamond',...
                        '^','v','>','<','p','pentagram',...
                        'h','hexagram','none'}
                    object.Marker=value;
                otherwise
                    error('ERROR: invalid marker');
            end
        end
        function object=set.MarkerStyle(object,value)
            assert(ischar(value),'ERROR: invalid marker style');
            value=lower(value);
            switch value
                case {'open','closed'}
                    object.MarkerStyle=value;
                otherwise
                    error('ERROR: invalid marker style');
            end
        end
        function object=set.MarkerSize(object,value)
            assert(isnumeric(value) & isscalar(value) & value>0,...
                'ERROR: invalid marker size');
            object.MarkerSize=value;
        end
        function object=set.Box(object,value)
            assert(ischar(value),'ERROR: invalid box value');
            value=lower(value);
            switch value
                case {'on','off'}
                    object.Box=value;
                otherwise
                    error('ERROR: invalid Box value');
            end
        end
        function object=set.AspectRatio(object,value)
            assert(ischar(value),'ERROR: invalid AspectRatio value');
            value=lower(value);
            switch value
                case {'auto','equal'}
                    object.AspectRatio=value;
                otherwise
                    error('ERROR: invalid AspectRatio value');
            end
        end
        function object=set.AxesColor(object,value)
            assert(SMASH.General.testColor(value),'ERROR: invalid AxesColor value');
            object.AxesColor=value;
        end
        function object=set.AxesLayer(object,value)
            assert(ischar(value),'ERROR: invalid AxesLayer value');
            value=lower(value);
            switch value
                case {'top' 'bottom'}
                    object.AxesLayer=value;
                otherwise
                    error('ERROR: invalid AxesLayer value');
            end
        end
        function object=set.XDir(object,value)
            assert(ischar(value),'ERROR: invalid XDir value');
            value=lower(value);
            switch value
                case {'normal','reverse'}
                    object.XDir=value;
                otherwise
                    error('ERROR: invalid XDir value');
            end
        end
        function object=set.YDir(object,value)
            assert(ischar(value),'ERROR: invalid YDir value');
            value=lower(value);
            switch value
                case {'normal','reverse'}
                    object.YDir=value;
                otherwise
                    error('ERROR: invalid YDir value');
            end
        end
        function object=set.Title(object,value)
            if ischar(value)
                object.Title=value;
            elseif iscell(value) && all(cellfun(@ischar,value))
                object.Title=value;
            else
                error('ERROR: invalid Title value');
            end 
        end
        function object=set.PanelColor(object,value)
            assert(SMASH.General.testColor(value),...
                'ERROR: invalid PanelColor value');
            object.PanelColor=value;
        end
        function object=set.ColorMap(object,value)
            result=false;
            if isnumeric(value)
                valid=(value>=0) & (value<=1);
                if (size(value,2)==3) && all(valid(:))
                    result=true;
                end
            elseif ischar(value)
                result=false;
                if exist(value,'file')
                    try
                        value=feval(value);
                        result=true;
                    catch
                        % do nothing
                    end
                elseif strcmpi(value,'coolwarm')
                    value=SMASH.MUI.Colormap.coolwarm();
                    result=true;
                end
            end
            assert(result,'ERROR: invalid ColorMap value');
            object.ColorMap=value;
        end
        function object=set.FigureColor(object,value)
            assert(SMASH.General.testColor(value),...
                'ERROR: invalid FigureColor value');
            object.FigureColor=value;
        end        
    end
end