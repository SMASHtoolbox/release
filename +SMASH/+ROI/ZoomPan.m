% ZoomPan Keyboard zoom/pan control
%
% This function enables keyboard-driven zoom and pan control.  The calling
% sequence is similar to MATLAB's zoom and pan commands.
%     ZoomPan('on'); % enable keyboard pan/zoom
%     ZoomPan('off') % disable keyboard pan/zoom
%     ZoomPan()      % toggle keyboard pan/zoom state
% Keyboard control pans and zooms with arrow keys instead of mouse clicks.
% The right arrow pans the current axes to the right by 2%, while the left
% arrow has the opposite effect; up/down arrows have similar effects in the
% vertical direction.  Arrows pressed in conjunction with the shift button
% change the zoom level by 50%: right/up increases and left/down decreases
% the zoom in the respective dimensions.  The "a" key auto scales and the
% "t" key tight scales the current axes.
%
% By default, keyboard control applies all axes in the current figure.
% Individual key commands are applied to the current axes, which can be
% changed with a mouse click.  Keyboard control can be enabled for any
% figure by passing its handle as the first input argument.
%    ZoomPan(fig,state);  
% To add a zoom/pan toggle tool on any figure.
%    tb=ZoomPan(fig,'addtoggle');
% The output "tb" is the toggle tool handle.  Only one zoom/pan toggle is
% allowed per figure, so "tb" may be an existing handle if a toggle was
% already present.
%
% See also SMASH.ROI
%    
function varargout=ZoomPan(varargin)

% manage input
switch nargin
    case 0
        fig=gcf;
        state='';
    case 1
        if ischar(varargin{1})
            fig=gcf;
            state=lower(varargin{1});
        elseif ishandle(varargin{1}) && strcmpi(get(varargin{1},'Type'),'figure')
            fig=varargin{1};
            state='';
        else
            error('ERROR: invalid input');
        end
    case 2
        assert(ishandle(varargin{1}) && strcmpi(get(varargin{1},'Type'),'figure'),...
            'ERROR: invalid figure');
        fig=varargin{1};
        assert(ischar(varargin{2}),'ERROR: invalid zoom/pan state');
        state=lower(varargin{2});
    otherwise
        error('ERROR: too many input arguments');
end

% check zoom/pan state
previous=getappdata(fig,'ZoomPan');
if isempty(previous)
    previous.State='off';
    previous.PressFcn='';
    previous.ReleaseFcn='';
end

if isempty(state)
    switch previous.State
        case 'on'
            state='off';
        case 'off'
            state='on';
    end
elseif strcmpi(state,'state')
    varargout{1}=previous.State;
    return
end

% update zoom/pan state
switch state
    case 'on'
        previous.Press=get(fig,'WindowKeyPressFcn');
        previous.Release=get(fig,'KeyReleaseFcn');
        previous.State='on';        
        set(fig,'WindowKeyPressFcn',@applyKey,'KeyReleaseFcn','');
        zoom(fig,'off');
        pan(fig,'off');
        datacursormode(fig,'off');
    case 'off'
        set(fig,'WindowKeyPressFcn',previous.PressFcn,...
            'KeyReleaseFcn',previous.ReleaseFcn);
        previous=[];
    case 'addtoggle'
        previous=findall(fig,'Tag','ZoomPan');
        if ~isempty(previous)
            varargout{1}=previous;            
            return
        end
        parent=findall(fig,'flat','Type','Toolbar');
        if isempty(parent)
            parent=uitoolbar(fig);
        else
            parent=parent(1);
        end
        icon=nan(16,16);
        index=[...
            2   6   7  14  18  21  23  29  30  31  34  36 ...
            39  44  46  48  50  51  55  62  78  82  83  84 ...
            85  86  87  94  98 101 110 114 117 126 130 131 ...
            132 133 142 158 172 174 176 179 185 189 190 191 ...
            194 202 206 209 210 211 212 213 214 215 216 217 ...
            218 219 226 234 243 249];
        icon(index)=0;
        icon=repmat(icon,[1 1 3]);
        varargout{1}=uitoggletool(parent,'CData',icon,'Tag','ZoomPan',...
            'ClickedCallback',@toggle,...
            'TooltipString','Enable zoom/pan with arrow keys');
        return
end
    function toggle(varargin)
        state=get(varargin{1},'State');
        state=char(state);
        packtools.call('ZoomPan',fig,state);
        switch state
            case 'on'
                set(varargin{1},'TooltipString',...
                    'Disable zoom/pan with arrow keys');
            case 'off'
                set(varargin{1},'TooltipString',...
                    'Enable zoom/pan with arrow keys');
        end
    end


%%
    function applyKey(~,data)
        target=get(fig,'CurrentAxes');
        % auto/tight scaling
        switch data.Key
            case {'leftarrow' 'rightarrow' 'uparrow' 'downarrow'}
                % continue
            case {'a' 't'}
                if strcmp(target.XLimMode,'manual')
                    xman=true;
                else
                    xman=false;
                end
                if strcmp(target.YLimMode,'manual')
                    yman=true;
                else
                    yman=false;
                end
                if strcmp(data.Key,'a')
                    axis(target,'auto');
                else
                    axis(target,'tight');
                end
                if xman
                    set(target,'XLim',target.XLim);
                end
                if yman
                    set(target,'YLim',target.YLim);
                end
                return
            otherwise
                return
        end
        
        if isempty(data.Modifier)
            panAxes(data);
        elseif numel(data.Modifier) == 1
            switch lower(data.Modifier{1})
                case 'shift'
                    zoomAxes(data);
                otherwise 
                    return
            end
        else
            return
        end        
    end

    function panAxes(data)
        target=get(fig,'CurrentAxes');
        xbound=get(target,'XLim');
        ybound=get(target,'YLim');
        Lx=xbound(2)-xbound(1);
        Ly=ybound(2)-ybound(1);
        ratio=0.02;
        switch data.Key
            case 'leftarrow'
                xbound=xbound-Lx*ratio;
            case 'rightarrow'
                xbound=xbound+Lx*ratio;
            case 'uparrow'
                ybound=ybound+Ly*ratio;
            case 'downarrow'
                ybound=ybound-Ly*ratio;
        end
        set(target,'XLim',xbound,'YLim',ybound);
    end

    function zoomAxes(data)
        target=get(fig,'CurrentAxes');
        xbound=get(target,'XLim');
        ybound=get(target,'YLim');
        xc=(xbound(1)+xbound(2))/2;
        Lx=xbound(2)-xbound(1);    
        yc=(ybound(1)+ybound(2))/2;
        Ly=ybound(2)-ybound(1);
        ratio=1.5;
        switch data.Key
            case 'leftarrow'
                Lx=Lx*ratio;
            case 'rightarrow'
                Lx=Lx/ratio;
            case 'uparrow'
                Ly=Ly/ratio;
            case 'downarrow'
                Ly=Ly*ratio;
        end
        xbound=xc+[-1 +1]*Lx/2;
        ybound=yc+[-1 +1]*Ly/2;
        set(target,'XLim',xbound,'YLim',ybound);
    end


setappdata(fig,'ZoomPan',previous);

% manage output
if nargout > 0
    varargout{1}=state;
end



end