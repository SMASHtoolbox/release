% focus Focus on allowed figures
%
% This method focuses MATLAB on a list of allowed figures.
%    SMASH.Graphics.FigureTools.focus(allowed); % handle graphics array
% Selecting any figure *not* on this list makes MATLAB focus on the most
% recently active allowed figure.
%
% Calling this method with no input returns the current list of allowed
% figures.
%    list=SMASH.Graphics.FigureTools.focus();
% Figure focus can be turned off:
%    SMASH.Graphics.FigureTools.focus('off');
% and restored to the previous defined state.
%    SMASH.Graphics.FigureTools.focus('on');
%
% NOTE: the command window does *not* count as a figure.  Unlike a modal
% figure, it is possible to switch back and forth between an allowed figure
% and the command window
%
% <a href="matlab:SMASH.System.showExample('Focus','+SMASH/+Graphics/+FigureTools')">Examples</a>
%
% See also SMASH.Graphics.FigureTools
%

%
% created December 8, 2017 by Daniel Dolan (Sandia National Laboratories)
% renamed and updated December 13, 2017 by Daniel Dolan
%    -Reorganized internal variables
%
function varargout=focus(allowed)

%
data=getappdata(groot,'FigureTools_focus');
if isempty(data)
    data.Allowed=[];
    data.Timer=timerfind('Tag','FigureTools_focus');
    if isempty(data.Timer)
        data.Timer=timer('Tag','FigureTools_focus',...
            'BusyMode','drop','ExecutionMode','fixedDelay',...
            'Period',0.02,'TimerFcn',@enforceFocus);
    end
end

% process input
running=strcmpi(data.Timer.Running,'on');
stop(data.Timer);
if nargin == 0
    % do nothing
elseif nargin == 1
    if strcmpi(allowed,'off')
        running=false;
    elseif strcmpi(allowed,'on')
        assert((numel(data.Allowed) > 0) && all(isgraphics(data.Allowed)),...
            'ERROR: no allowed figures specified');
        running=true;
    elseif strcmpi(allowed,'reset')
        running=false;
        rmappdata(groot,'FigureTools_focus');
    elseif all(ishghandle(allowed))
        running=true;
        for n=1:numel(allowed)
            allowed(n)=ancestor(allowed(n),'figure');
        end
        data.Allowed=allowed;        
    else
        error('ERROR: invalid figure handle(s)');
    end
else
    error('ERROR: too many inputs');
end
setappdata(groot,'FigureTools_focus',data);

if running
    fig=findall(groot,'WindowStyle','modal');
    set(fig,'WindowStyle','normal');
    if numel(data.Allowed) > 0
        figure(data.Allowed(1));
        start(data.Timer);
    else
        stop(data.Timer);
    end
end

    function enforceFocus(varargin)
        data=getappdata(groot,'FigureTools_focus');
        keep=isgraphics(data.Allowed);
        if any(~keep)
            data.Allowed=data.Allowed(keep);
            if isempty(data.Allowed)
                stop(data.Timer);
            else
                figure(data.Allowed(1));
            end 
            setappdata(groot,'FigureTools_focus',data)
            return
        end        
        %
        current=get(groot,'CurrentFigure');
        if isempty(current)
            figure(data.Allowed(1));
            setappdata(groot,'FigureTools_focus',data)
            return
        end
        index=(current == data.Allowed);
        if index(1)
            % do nothing
        elseif any(index)
            data.Allowed=[data.Allowed(index) data.Allowed(~index)];            
        else
            color=current.Color;
            if all(color == [1 0 0])
                current.Color='y';
            else
                current.Color='r';
            end          
            state=pause();
            pause on;
            pause(0.01);
            pause(state);
            SMASH.System.simulateMouse('release');
            current.Color=color;
            figure(data.Allowed(1));
        end
        setappdata(groot,'FigureTools_focus',data)
    end

% manage output
if nargout > 0
    varargout{1}=data.Allowed;
end

end