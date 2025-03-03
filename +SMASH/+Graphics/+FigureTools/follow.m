% follow Link figure positions
%
% This method links a group of figures into a family:
%    follow(family);
% The input "family" is an array of at least two figure handles.  The first
% handle is defined as the parent, and all subsequent handles are
% dependents.  Dependent figures move with the parent figure, but the
% parent figure does not move with its dependents.
%
% Dependent figures that move beyond the the edges of a monitor are pushed
% back inward unless additional space is availabe on another monitor; the
% parent figure is *not* pushed back.  Dependent figures partially located
% on a new monitor may be shifted fully onto that monitor.  It either case,
% the relative parent-dependenty figure positions will change.
%
% Multiple families can be defined:
%    follow(familyA,familyB,...)
% can be defined with distinct parent-dependent relationships.
%
% Family motion is disabled when any of the figures are closed, and new
% calls to this method disables existing family relationships. The command:
%    follow('off'); 
% disables all family following.  The most recent family defintions can be
% restored:
%    follow('on');
% if all the linked figures still exist.
%
% NOTE: there is some overhead for figure following, so it may be helpful
% to disable this feature during intensive calculations. 
%
% <a href="matlab:SMASH.System.showExample('Follow','+SMASH/+Graphics/+FigureTools')">Examples</a>
%
% See also SMASH.Graphics.FigureTools
%

%
% created December 11, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=follow(varargin)

data=getappdata(groot,'FigureTools_follow');
if isempty(data) || ~isvalid(data.Timer)
    temp=timerfindall('Tag','FigureTools_follow');
    if isempty(temp)
        data.Timer=timer('BusyMode','drop','ExecutionMode','fixedDelay',...
            'Period',0.02,'TimerFcn',@followParent,'Tag','FigureTools_follow');
    else
        data.Timer=temp;
    end
    data.Group={};
end

% manage input
assert(nargin > 0,'ERROR: insufficient input');
if (nargin == 1) && ischar(varargin{1})
    switch lower(varargin{1})
        case 'on'
            assert(~isempty(data.Group),'ERROR: no follow groups defined');
            followParent('reset');
            if strcmpi(data.Timer.Running,'off')
                start(data.Timer);
            end
        case 'off'
            if strcmpi(data.Timer.Running,'on')
                stop(data.Timer);
            end            
        otherwise
            error('ERROR: follow can only be turned on or off');
    end
    setappdata(groot,'FigureTools_follow',data)
    return
end

stop(data.Timer);
group={};
for m=1:nargin
    if all(isgraphics(varargin{m}))
        temp=varargin{m};
        assert(numel(temp) >= 2,'ERROR: follow groups must have least two figures');
        for n=1:numel(temp)
            temp(n)=ancestor(temp(n),'figure');
        end
        group{end+1}=temp; %#ok<AGROW>
    else
        error('ERROR: invalid input');
    end
end
data.Group=group;

setappdata(groot,'FigureTools_follow',data);
followParent('reset');
start(data.Timer);

% manage output
if nargout > 0
    varargout{1}=data;
end

%%
    function followParent(varargin)        
        persistent origin offset
        data=getappdata(groot,'FigureTools_follow');
        M=numel(data.Group);
        if isempty(origin)
            origin=nan(M,2);
            for mm=1:M
                temp=getpixelposition(data.Group{1}(1));
                origin(mm,:)=temp(1:2);
            end
        end
        if isempty(offset) || strcmp(varargin{1},'reset')
            for mm=1:M
                N=numel(data.Group{mm});
                offset{mm}=nan(N,2);
                for nn=1:N
                    temp=getpixelposition(data.Group{mm}(nn))...
                        -getpixelposition(data.Group{mm}(1));
                    offset{mm}(nn,:)=temp(1:2);
                end
            end
        end
        %
        active=true(M,1);
        for mm=1:M
            if ~all(isgraphics(data.Group{mm}))
                active(mm)=false;
                continue
            end
            current=getpixelposition(data.Group{mm}(1));
            current=current(1:2);
            change=any(abs(current-origin(mm,:)) > 1);
            N=numel(data.Group{mm});
            origin(mm,:)=current;
            for nn=2:N
                temp=getpixelposition(data.Group{mm}(nn));
                if change
                    temp(1:2)=origin(mm,:)+offset{mm}(nn,:);                                        
                    setpixelposition(data.Group{mm}(nn),temp);
                    movegui(data.Group{mm}(nn),'onscreen');
                else
                    temp=temp(1:2)-origin(mm,:);
                    offset{mm}(nn,:)=temp;
                end
            end
        end       
        if ~all(active)
            %fprintf('FigureTools.follow disabled\n');
            stop(data.Timer);
        end
        setappdata(groot,'FigureTools_follow',data);
    end

end

