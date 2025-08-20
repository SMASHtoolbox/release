% This class manages options for graphical display.
%
% See also General, Options
%

%
% created November 17, 2014 by Daniel Dolan (Sandia National Laboratory)
%
classdef PlotOptions < SMASH.General.Options
    %%
    methods (Hidden=true)
        function object=PlotOptions(varargin)
            % line properites
            object=add(object,'LineStyle','-',{'-','--','-.',':','none'});
            object=describe(object,'LineStyle',...
                'LineStyle: (any MATLAB line style)',...
                'locked');

            object=add(object,'LineColor','k',@verifyColor);
            object=describe(object,'LineColor',...
                'LineColor: RGB value or short/long name ',...
                'locked');
   
            object=add(object,'LineWidth',1,@verifyWidth);
            object=describe(object,'LineWidth',...
                'LineWidth: width in points',...
                'locked');
  
            object=add(object,'Marker','o',...
                {'+','o','*','.','x','s','square','d','diamond','^','v','>','<','p','pentagram','h','hexagram','none'});
            object=describe(object,'Marker',...
                'LineMarker: (all MATLAB marker symbol)','lock');
     
            object=add(object,'MarkerStyle','open',{'open','closed'});
            object=describe(object,'MarkerStyle',...
                'MarkerStyle: ''open'' or ''closed''',...
                'locked');
       
            object=add(object,'MarkerSize',5,@verifyWidth);
            object=describe(object,'MarkerSize',...
                'MarkerSize: size in points',...
                'locked');
            
            % axes properties
            object=add(object,'Box','on',{'on','off'});
            object=describe(object,'Box',...
                'Box: ''on'' or ''off''');
            
            object=add(object,'AspectRatio','auto',{'auto','equal'});
            object=describe(object,'AspectRatio',...
                'AspectRatio: ''auto'' or ''equal''');           
            
            object=add(object,'AxesColor','w',@verifyColor);
            object=describe(object,'AxesColor',...
                'AxesColor: RGB value or short/long name');
            
           object=add(object,'XDir','normal',{'normal', 'reverse'});
           object=describe(object,'XDir',...
               'XDir: ''normal'' or ''reverse''','locked');
           
           object=add(object,'YDir','normal',{'normal', 'reverse'});
           object=describe(object,'YDir',...
               'YDir: ''normal'' or ''reverse''','locked');
            
            % uipanel properties
            object=add(object,'PanelColor',...
                get(0,'DefaultUIPanelBackgroundColor'),@verifyColor);
            object=describe(object,'PanelColor',...
                'PanelColor: RGB value or short/long name');
            
            % figure properties
            object=add(object,'ColorMap',jet(64),@verifyColorMap);
            object=describe(object,'ColorMap',...
                'ColorMap: Three-column table or name (e.g., ''jet'')',...
                'locked');
            
            object=add(object,'FigureColor',...
                get(0,'DefaultFigureColor'),@verifyColor);
            
            object=describe(object,'FigureColor',...
                'AxesColor: RGB value or short/long name');
        end        
    end
    
end

%%
function result=verifyColor(value)

result=false;
if isnumeric(value)
    if (numel(value)==3) && all(value>=0) && all(value<=1)
        result=true;
    end
    return
end

if ischar(value)
    switch lower(value)
        case {'y','yellow'}
            result=true;
        case {'m','magenta'}
            result=true;
        case {'c','cyan'}
            result=true;
        case {'r','red'}
            result=true;
        case {'g','green'}
            result=true;
        case {'b','blue'}
            result=true;
        case {'w','white'}
            result=true;
        case {'k','black'}
            result=true;
    end
    return
end

end

function result=verifyWidth(value)

result=false;
if isnumeric(value)
    if value>0
        result=true;
    end
    return
end
end

function result=verifyColorMap(value)

result=false;
if isnumeric(value)
    valid=(value>=0) & (value<=1);
    if (size(value,2)==3) && all(valid(:))
        result=true;
    end
elseif ischar(value)
    if exist(value,'file')
        result=true;
    end
end


end