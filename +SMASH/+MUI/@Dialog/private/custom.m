% dialog.custom : add a line of custom uicontrols
%
% Usage:
%
%   >> h=object.custom(object,{Control},{labels},[minwidth], height,{Choices},Rows);
%
% This function allows for the generation of a series of arbitrary controls
% aligned horizontally.  It is designed to provide more flexibility for
% situations where the more common combined controls, like edit_button, are
% insufficient.  Two arguments must be passed to this function:  the object
% and a cell array of strings representing the controls to be added in
% horizonatal order from left to right.  If no other options are passed,
% the defaults for each control option are used.  The labels input should
% be a cell array of strings.  If there are more controls specified than
% labels, the labels are applied sequentially and all remaining controls
% recieve the default label.  If no label is desired for an edit or slider
% control, passing a label of 'skiplabel' will remove them.  Minwdith
% represents the minimum width of each control from left to right.  It
% should be an array of numbers.  If the number of elements specified in
% minwidth is less than the number of controls, the last number specified
% in minwidth is applied to all remaining controls.  The height input is
% applied only to 'medit' controls and specified the number of lines.  It
% should be an array of numbers.  If the number of elements specified in
% height is less than the number of controls, the last number specified is
% applied to all remaining controls.  the choices input applies to
% 'listbox' and 'popup' controls.  It should be a cell array where each
% entry is a cell array of strings representing all the choices for each
% object to be applied sequentially.  The rows input applies on to
% 'tables'.  It should be an array of numbers representing the number of
% rows for each table sequentially.  If the number of elements in rows is
% less than the number of controls specified, the last number specified in
% rows is applied to all remaining tables.

function varargout=custom(object,Control,varargin)

%error checking
verify(object);
if (nargin<2) || isempty(Control)
    error('ERROR: no controls specified');
end
if ~iscellstr(Control)
    error('Error: Controls must be specified as a cell array of strings');
end

%generate initial inputs
N=numel(Control);
label=cell(1,N);
minwidth=zeros(1,N);
height=minwidth;
choices=label;
rows=minwidth;
%use the passed inputs to modify the initial inputs
ind=ones(1,3);
for k=1:numel(varargin)
    n=numel(varargin{k});
    if k == 1
        if ~iscell(varargin{k})
            error('Error: Labels must be specified as a cell array of strings');
        end
        for m=1:min([n,N])
            label{m}=varargin{k}{m};
        end
    elseif k == 2
        if ~isnumeric(varargin{k})
            error('Error: Minwidth must be specified as an array');
        end
        for m=1:N
            if m <= n
                minwidth(m)=varargin{k}(m);
            else
                minwidth(m)=varargin{k}(end);
            end
        end
    elseif k == 3
        if ~isnumeric(varargin{k})
            error('Error: Height must be specified as an array');
        end
        for m=1:N
            switch lower(Control{m})
                case 'medit'
                    height(m)=varargin{k}(ind(1));
                    if numel(varargin{k}) > ind(1)
                        ind(1)=ind(1)+1;
                    end
            end
        end
    elseif k == 4
        if ~iscell(varargin{k})
            error('Error: Choices must be specified as a cell array of strings');
        end
        for m=1:N
            switch lower(Control{m})
                case {'list','listbox','popup'}
                    choices{m}=varargin{k}{ind(2)};
                    if numel(varargin{k}) > ind(2)
                        ind(2)=ind(2)+1;
                    end
            end
        end
    elseif k == 5
        if ~isnumeric(varargin{k})
            error('Error: Rows must be specified as an array');
        end
        for m=1:N
            switch lower(Control{m})
                case 'table'
                    rows(m)=varargin{k}(ind(3));
                    if numel(varargin{k}) > ind(3)
                        ind(3)=ind(3)+1;
                    end
            end
        end
    end
end
%generate each control vertically using the addblock commands for each
h=[];
a=[];
removed=0;
for k=1:numel(Control)
    switch lower(Control{k})
        case 'text'
            h(end+1)=text(object,label{k},minwidth(k));
        case 'edit'
            switch lower(label{k})
                case 'skiplabel'
                    h(end+1:end+2)=edit(object,' ',minwidth(k),'skiplabel');
                otherwise
                    h(end+1:end+2)=edit(object,label{k},minwidth(k));
            end
        case 'medit'
            h(end+1:end+2)=medit(object,label{k},minwidth(k),height(k));
        case {'button','buttons'}
            h(end+1)=button(object,label{k},minwidth(k));
        case {'check','checkbox'}
            h(end+1)=check(object,label{k},minwidth(k));
        case {'list','listbox'}
            h(end+1:end+2)=listbox(object,label{k},choices{k},minwidth(k));
        case 'popup'
            switch lower(label{k})
                case 'skiplabel'
                    h(end+1:end+2)=popup(object,label{k},choices{k},minwidth(k),'skiplabel');
                otherwise
                    h(end+1:end+2)=popup(object,label{k},choices{k},minwidth(k));
            end
        case 'radio'
            h(end+1:end+numel(label{k}))=radio(object,label{k},minwidth(k));
        case 'toggle'
            h(end+1)=toggle(object,label{k},minwidth(k));
        case 'table'
            n=numel(label{k});
            h(end+1:end+n+1)=table(object,label{k},minwidth(k),rows(k));
        case 'slider'
            switch lower(label{k})
                case 'skiplabel'
                    h(end+1:end+3)=slider(object,' ',minwidth(k),'skiplabel');
                otherwise
                    h(end+1:end+3)=slider(object,label{k},minwidth(k));
            end
        otherwise
            error('ERROR: %s is not a supported dialog style',Control{k});
    end
    %identify all NaN outputs to make reordering of the controls easier
    %Store all output for each control (ignoring labels) in "a"
    if numel(h) > 1
        if isnan(h(numel(h)-1));
            removed=removed+1;
        end
            a(end+1)=numel(h)-removed;
    else
        a(end+1)=numel(h);
    end
end
%eliminate NaN in the output array
h=h(~isnan(h));
%get the control handles for each created
hands=get(object.Handle,'Children');
index=numel(h);
%reorder a to match hands
a=index-a+1;
spacer=object.HorizontalGap;
pos=zeros(index,4);
%get initial positions of each control
for m=1:index
    pos(m,1:4)=hands(m).Position;
end
%get the top location of the upper most control
[gap,ind]=max(pos(:,2));
gap=gap+pos(ind,4);
%arrange the controls horizontally at the bottom of the object
top=0;
for n=1:numel(a)
    if n == 1
        start=spacer;
    end
    hands(a(n)).Position=[start object.VerticalGap pos(a(n),3) pos(a(n),4)];
    start=start+pos(a(n),3)+spacer;
    %save the highest top postion for rearranging any prior controls
    top=max([top object.VerticalGap+pos(a(n),4)]);
end
%align the controls just incase everything isn't placed properly
align(hands(a),'None','Top');
%Now move all the labels ontop of their corresponding controls
for p=1:numel(a)
    if p == 1
        N=index+1;
    else
        N=a(p-1);
    end
    if a(p) ~= (N-1)
        loc=hands(a(p)).Position;
        for q=a(p)+1:(N-1)
            hands(q).Position=[loc(1)+(pos(q,1)-pos(a(p),1)) loc(2)+(pos(q,2)-pos(a(p),2)) pos(q,3) pos(q,4)];
            %store the highest top of the labels for rearranging any prior
            %controls
            top=max([top,loc(2)+(pos(q,2)-pos(a(p),2))+pos(q,4)]);
        end
    end
end
%push all prior controls in the box down so they are aligned above the
%custom controls just created
C=get(object.Handle,'Children');
for k=numel(h)+1:numel(C)
    C(k).Position(2)=C(k).Position(2)-(gap-top);
end
%resize the object to remove all the empty top space
make_room(object);

%update the object
object.Controls(end+1:end+numel(h))=h;

%generate the output
if nargout>=1
    varargout{1}=h;
end




