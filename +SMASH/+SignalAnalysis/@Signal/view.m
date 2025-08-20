% VIEW View Signal object graphically
%
% This method displays Signal objects as line plots, which are drawn in a
% new figure by default.
%    >> view(object); 
%    >> h=view(object); % return line's graphic handle
% The line's properties (color, width, etc.), axes labels, and title are
% defined by the object.
%
% To display the signal in an existing figure, pass a graphic handle as a
% second input.
%    >> [...]=view(object,target);
% If target is a valid axes handle, the Signal is drawn without altering
% the title or axes labels.  Passing a figure handle causes the Signal to
% be drawn in the current axes and overwrites the labels; if no axes is
% present, a new one is created.
%
% See also Signal
%

%
% created November 21, 2013 by Daniel Dolan (Sandia National Laboratories) 
%
function varargout=view(object,target)

% error checking
[time,value]=limit(object);
assert(numel(time) > 0,'ERROR: object has no data');

% handle input
new=false;
if (nargin<2) || isempty(target)
    %target=figure;   
    target=SMASH.MUI.Figure;
    target=target.Handle;
    set(target,'NumberTitle','on','Name','Signal view');
    new=true;
elseif ~ishandle(target)
    error('ERROR: invalid target handle');
end

switch lower(get(target,'Type'))
    case 'axes'
        fig=ancestor(target,'figure');
    case 'figure'
        fig=target;
        target=get(fig,'CurrentAxes');
        if isempty(target)
            target=axes('Parent',fig);
        end
        new=true;
    otherwise
        error('ERROR: invalid target handle');
end
set(fig,'CurrentAxes',target);

% create line with object's properties
if isreal(value)
    h=line(time,value);
else
    value=[real(value) imag(value)];
    temp=SMASH.SignalAnalysis.SignalGroup(time,value);
    h=view(temp,1:2,target);
    if new
        legend('Real part','Imaginary part');
        xlabel(object.GridLabel);
        ylabel(object.DataLabel);
    end
    if nargout>=1
        varargout{1}=h;
    end
    return
end

% fill out new figure
if new
    xlabel(target,object.GridLabel);
    ylabel(target,object.DataLabel);
    apply(object.GraphicOptions,h);
else
    apply(object.GraphicOptions,h,'noparent');
end

set(0,'CurrentFigure',fig);

% handle output
if nargout>=1
    varargout{1}=h;
end

end