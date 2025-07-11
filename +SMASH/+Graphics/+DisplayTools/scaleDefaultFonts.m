% scaleDefaultFonts Scale default font sizes
%
% This function adjusts the font size used in MATLAB figures. Scaling is
% specified as a percentage of the default font size.
%    scaleDefaultFonts(value);
% For example, a scale factor of 200 doubles the font size while a scale
% factor of 50 halves it.  Default scaling is restored with a scale
% factor of 100 or 'default'.
% 
% Automatic scaling:
%    scaleDefaultFonts('auto');
% is based on the primary display resolution and MATLAB's
% ScreenPixelPerInch setting.
%
% NOTE: only text created *after* the function call are rendered larger or
% smaller.  Existing figures are unaffected.
% 
% Calling this function with no input:
%    scaleDefaultFonts();
% allows interactive selection of the scale factor.
%
% This function returns to the current scale factor as an output.
%    value=scaleDefaultFonts(...);
% Calling the function with an empty input and no output:
%    scaleDefaultFonts([]);
% prints the scale factor in the command window.
% 
% See also SMASH.Graphics.DisplayTools, scaleFigure
%

%
% created November 30, 2017 by Daniel Dolan (Sandia National Laboratories)
% revised January 24, 2018 by Daniel Dolan
%    -moved from static method to a package function
%
function varargout=scaleDefaultFonts(value)

data=getappdata(0,'scaleDefaultFonts');
if isempty(data)
    temp=get(0,'factory');
    name=fieldnames(temp);
    list={};
    for k=1:numel(name)
        if regexpi(name{k},'FontSize') % possible match            
            if regexpi(name{k},'Multiplier')
                % invalid match
            else
                list{end+1}=name{k}(8:end); %#ok<AGROW>
                continue % valid match
            end
        end      
    end
    data.Value=100;
    data.List=list;
    setappdata(0,'scaleDefaultFonts',data);
else
    list=data.List;
end

% manage input
if nargin < 1
    value=showFontScaling();
elseif strcmpi(value,'default')
    value=100; % percent
elseif strcmpi(value,'auto')
    value=getScreenResolution()/get(0,'ScreenPixelsPerInch')*100;
elseif ischar(value)
    error('ERROR: invalid scale value');
end

% apply scaling
probe=false;
if isempty(value)
    probe=true;
    factory=get(0,sprintf('factory%s',list{1}));
    default=get(0,sprintf('default%s',list{1}));
    value=default/factory*100;
else
    if (value < 50) || (value > 200)
        warning('Extreme font scaling (<50% or >200%) may result in strange graphic appearance');
    end
    for k=1:numel(list)
        factory=get(0,sprintf('factory%s',list{k}));
        set(0,sprintf('default%s',list{k}),factory*value/100)
    end
end
data.Value=value;
setappdata(0,'scaleDefaultFonts',data);

% manage output
if nargout == 0
    if probe
        fprintf('Scale factor is %g%%\n',value);
    end
else
    varargout{1}=value;
    %varargout{2}=object;
end
    
end

function value=showFontScaling()

value=[];

%% create dialog
fig=figure('Visible','off','NumberTitle','off',...
    'Name','Font scaling',...
    'Menubar','none','Toolbar','none',...
    'Resize','off','DockControls','off');
set(fig,'DefaultUIControlFontSize','factory');

margin=10;

done=uicontrol(fig,'Style','pushbutton','String','Done');
cancel=uicontrol(fig,'Style','pushbutton','String',' Cancel ');
L=1.5*max(done.Extent(3),cancel.Extent(3));
done.Position([1 3])=[margin L];
cancel.Position([1 3])=[margin L];
cancel.Position(1)=done.Position(1)+margin+cancel.Position(3);
L=1.5*max(done.Extent(4),cancel.Extent(4));
done.Position([2 4])=[margin L];
cancel.Position([2 4])=[margin L];
align([done cancel],'Distribute','Center');

temp{1}=char(65:90); % upper case letters
temp{2}=char(97:122); % lower case letters
temp{3}=sprintf('%d',0:9);
sample=uicontrol(fig,'Style','edit','Max',2,'String',temp,...
    'HorizontalAlignment','left');
sample.Position(1)=margin;
sample.Position(2)=done.Position(2)+sample.Position(4)+margin;
sample.Position(3)=2*sample.Extent(3);
sample.Position(4)=1.5*sample.Extent(4);

label=uicontrol(fig,'Style','text','String','Sample text:','FontWeight','bold');
label.Position(1)=margin;
label.Position(2)=sample.Position(2)+sample.Position(4);
label.Position(3)=label.Extent(3);
label.Position(4)=label.Extent(4);
y0=label.Position(2)+label.Position(4)+margin;

StdValues=[50 75 100 125 150 175 200];
StdString=cell(size(StdValues));
for n=1:numel(StdValues)
    StdString{n}=sprintf('%g%%',StdValues(n));
end
StdString{n+1}='custom';
standard=uicontrol(fig,'Style','popup','String',StdString);
standard.Position(1)=margin;
standard.Position(2)=y0;
standard.Position(3)=100;
custom=uicontrol(fig,'Style','edit','String','100','UserData','100');
custom.Position(1)=standard.Position(1)+standard.Position(3);
custom.Position(2)=y0;
custom.Position(3)=2*custom.Extent(3);
custom.Position(4)=1.5*custom.Extent(4);
align([standard custom],'Distribute','Bottom');
y0=standard.Position(2)+standard.Position(4);

label=uicontrol(fig,'Style','text','String',...
    'Scale value:','FontWeight','bold');
label.Position(1)=margin;
label.Position(2)=y0;
label.Position(3)=label.Extent(3);
label.Position(4)=label.Extent(4);

hc=get(fig,'Children');
width=0;
height=0;
for n=1:numel(hc)
    hc(n).Units='pixels';
    width=max(width,hc(n).Position(1)+hc(n).Position(3));
    height=max(height,hc(n).Position(2)+hc(n).Position(4));
end
fig.Units='pixels';
fig.Position(3)=width+margin;
fig.Position(4)=height+margin;

%% callbacks
set(standard,'Callback',@pickStandard)
    function pickStandard(varargin)
        choice=get(standard,'Value');
        if choice <= numel(StdValues)
            custom.String=StdString{choice};
        else
            custom.String=custom.UserData;
        end
        pickCustom();
    end

set(custom,'Callback',@pickCustom)
    function pickCustom(varargin)
        temp=sscanf(custom.String,'%g',1);
        if isempty(temp)
            custom.String=custom.UserData;
            return
        end
        custom.String=sprintf('%g',temp);
        custom.UserData=custom.String;
        if any(temp == StdValues)
            standard.Value=find(temp == StdValues);
        else
            standard.Value=numel(StdString);
        end        
        sample.FontSize=get(0,'FactoryUIControlFontSize')*temp/100;
    end

set([done cancel],'Callback',@killFigure)
    function killFigure(src,varargin)
        if strcmpi(get(src,'String'),'done')
            value=sscanf(custom.String,'%g',1);           
        end
        delete(fig);
    end

%%
data=getappdata(0,'scaleDefaultFonts');
previous=data.Value;
custom.String=sprintf('%g',previous);
pickCustom();

movegui(fig,'center');
set(fig,'WindowStyle','modal','Visible','on');
%figure(fig);
uiwait(fig);

end