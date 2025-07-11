% refresh Refresh interface
%
% This method refreshes an interface, updating the object and display as
% necesary.  Calling the method:
%    refresh(object);
% does several things.
%    -Axes and button handles are verified.
%    -Buttons are positioned on the screen
%    -Graphic and button panels are resized to match the current button
%    state.
% This method should be called whenever axes/button objects are removed
% from the interface.  
%
% See also BasicGUI
%

%
% created December 2, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function refresh(object,choice)

% manage input
refreshAxes=false;
refreshButton=false;
if (nargin<2) || isempty(choice)
    choice='all';
end
assert(ischar(choice),'ERROR: invalid refresh choice');
switch lower(choice)
    case 'axes'
        refreshAxes=true;
    case 'button'
        refreshButton=true;
    case 'all'
        refreshAxes=true;
        refreshButton=true;
    otherwise
        error('ERROR: invalid refresh choice');
end

% axes objects
if refreshAxes
    keep=false(size(object.AxesObject));
    N=numel(keep);
    for n=1:N
        if ishandle(object.AxesObject(n))
            keep(n)=true;
        end
    end
    object.AxesObject=object.AxesObject(keep);
end

% button objects and panel
if refreshButton
    %
    keep=false(size(object.ButtonObject));
    N=numel(keep);
    for n=1:N
        if ishandle(object.ButtonObject(n))
            keep(n)=true;
        end
    end
    object.ButtonObject=object.ButtonObject(keep);
    
    if any(keep)
        set(object.ButtonPanel,'Visible','on');
    else
        set(object.ButtonPanel,'Visible','off');
    end
    N=sum(keep);
    %
    object.BPwidth=0;
    object.BPheight=0;
    x0=object.BPmargin;
    y0=object.BPmargin;
    for n=1:N
        position=get(object.ButtonObject(n),'Position');
        position(1)=x0;
        position(2)=y0;
        set(object.ButtonObject(n),'Position',position);
        x0=position(1)+position(3)+object.BPmargin;
        object.BPwidth=x0;
        object.BPheight=max(object.BPheight,position(4));
    end
    if N>0
        object.BPheight=object.BPheight+2*object.BPmargin;
    end
    %  
    if object.BPheight>0
        %
        set(object.ButtonPanel,'Units','pixels');
        position=get(object.ButtonPanel,'Position');
        position(4)=object.BPheight;
        set(object.ButtonPanel,'Position',position);
        %
        set(object.ButtonPanel,'Units','normalized');
        position=get(object.ButtonPanel,'Position');
        position(3)=1;
        set(object.ButtonPanel,'Position',position);
        %
        position(2)=position(4);
        position(4)=1-position(2);
        set(object.AxesPanel,'Position',position);
        %
        set(object.ButtonPanel,'Visible','on');
    else
        set(object.AxesPanel,'Position',[0 0 1 1]);
        set(object.ButtonPanel,'Visible','off');
    end
end

% update GUI size
resize(object,object.Figure.Handle)

end