% scaleFigure Scale figure
%
% This function scales the displayed size of a MATLAB figure.  
%    scaleFigure(factor); % scale figure by specified factor
%    scaleFigure('auto'); % automatic scaling
% The input "factor" must be a number greater than zero (in percent) or
% 'auto', which determines a scale factor based on the current display
% resolution.
%
% Scaling modifies the size of graphic objects that have physical units:
% inches, centimeters, or points; objects using pixels or normalized units
% are *not* modified.  Scaled figures use pixels units, while all objects
% inside the figure use normalized units.
%
% Sequentially scaling always refers to original figure size:
% between operations.  For example:
%    scaleFigure(150);
%    scaleFigure(200);
% results in a net scaling of 200%, not 300%.  Scaling by 100%
%    scaleFigure(100);
% reverts the figure to its original size and units, but all objects within
% the figure remain in normalized units.
%
% This function scales the current figure by default.  Passing a second
% input:
%    scaleFigure(factor,fig); % figure handle(s)
% resizes a particular figure or set of figures.  The second input can also
% be flag indicating different types of figures.
%    scaleFigure(factor,'visible'); % all figures with visible handles
%    scaleFigure(factor,'all'); % all figures, regardless of handle visibility
%   
% Scaling should be done *after* all objects are created!!
% 
% See also SMASH.Graphics.DisplayTools
%

function scaleFigure(value,fig)

% manage input
reset=false;
if (nargin < 1) || isempty(value)
    value=100;
elseif strcmpi(value,'auto')
    report=SMASH.Graphics.DisplayTools.checkDisplay;
    report=report(1);
    value=report.ActualResolution/report.SetResolution*100;
elseif strcmpi(value,'reset')
    reset=true;
    value=100;
else
    assert(SMASH.General.testNumber(value,'positive','notzero'),...
        'ERROR: invalid scale factor');
end
if (value < 50) || (value > 200)
    warning('Extreme scaling (<50% or >200%) may result in strange graphic appearance');
end

if (nargin < 2) || isempty(fig)
    fig=gcf;
elseif strcmpi(fig,'visible')
    fig=findobj(groot,'Type','figure');
elseif strcmpi(fig,'all')
    fig=findall(groot,'Type','figure');
else
    assert(ishandle(fig),'ERROR: invalid figure handle');    
end

% deal with multiple figures
if numel(fig) > 1
    for n=1:numel(fig)
        packtools.call('scaleFigure',value,fig(n));
    end
    return
end

% verify figure
assert(strcmpi(fig.Type,'figure'),'ERROR: invalid figure handle');

switch lower(fig.Units)
    case {'inches' 'centimeters' 'points' 'characters'}
        if strcmpi(fig.Resize,'on')
            warning('Resize disabled for scaled figures with physical units');
            fig.Resize='off';
        end
end

visible=strcmpi(fig.Visible,'on');
fig.Visible='off';
h=findall(fig);
for n=1:numel(h)
    if isprop(h(n),'Units')
       if ~isappdata(h(n),'OriginalSize') || reset
           try
               setappdata(h(n),'OriginalSize',h(n).Position(3:4));
           catch               
           end
           setappdata(h(n),'OriginalUnits',h(n).Units);
       end

       OriginalSize=getappdata(h(n),'OriginalSize');   
       OriginalUnits=getappdata(h(n),'OriginalUnits');
       switch lower(h(n).Units)
           case {'inches' 'centimeters' 'points' 'characters'}
               pos=getpixelposition(h(n));
               origin=pos(1:2)+pos(3:4)/2;
               units=h(n).Units;
               h(n).Units=OriginalUnits;
               h(n).Position(3:4)=OriginalSize*value/100;
               h(n).Units=units;
               pos=getpixelposition(h(n));
               pos(1:2)=origin-pos(3:4)/2;
               setpixelposition(h(n),pos);
       end
       drawnow;
    end
    if isprop(h(n),'FontUnits') %&& ~strcmpi(h(n).Parent.Type,'axes')
        if strcmpi(h(n).Parent.Type,'axes')
            ScaleText=true;
            list={'XLabel' 'YLabel' 'ZLabel' 'Title'};
            for k=1:numel(list)
                if h(n) == h(n).Parent.(list{k})
                    ScaleText=false;
                end
            end         
            if ~ScaleText
                continue
            end
        end
        if ~isappdata(h(n),'OriginalFontSize') || reset
            setappdata(h(n),'OriginalFontSize',h(n).FontSize);
        end
        OriginalFontSize=getappdata(h(n),'OriginalFontSize');
        switch lower(h(n).FontUnits)
           case {'inches' 'centimeters' 'points' 'characters'}
               h(n).FontSize=OriginalFontSize*value/100;
       end
    end   
end
if visible
    fig.Visible='on';
end

%movegui(fig,'onscreen');

end