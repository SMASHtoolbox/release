% copy Copy dialog items
%
% This method copies controls, tables, and other items from from a dialog
% box to another parent object.
%    new=copy(object,parent);
% The input "parent" can be a figure, uipanel, or uitable object.  The
% output "new" is an array of copied object handles.
%
% NOTE: new parent objects are resized to match the current size of the
% dialog box.
%
% See also Dialog
%

%
% created March 8, 2018 by Daniel Dolan (Sandia National Laboratories)
% 
function varargout=copy(object,parent)

% manage input
assert(nargin > 1,'ERROR: no parent object specified');

errmsg='ERROR: invalid parent object';
assert(isscalar(parent) && ishandle(parent),errmsg);
switch lower(get(parent,'Type'))
    case {'figure' 'uipanel'}
        master=parent;        
    case 'uitab'
        master=parent.Parent;        
    otherwise
        error(errmsg);
end

% copy children
h=get(object.Handle,'Children');
new=h;
for n=1:numel(h)
    if isprop(h(n),'Units')
        h(n).Units='pixels';
    end
    if isprop(h(n),'FontUnits')
        h(n).FontUnits='pixels';
    end
    new(n)=copyobj(h(n),parent);
end

% resize master
DialogPosition=getpixelposition(object.Handle);
MasterPosition=getpixelposition(master);
switch lower(get(parent,'Type'))
    case {'figure' 'uipanel'}
        MasterPosition(3:4)=DialogPosition(3:4);
        setpixelposition(master,MasterPosition);
    case 'uitab'
        units=get(master,'Units');
        set(master,'Units','pixels');
        width=DialogPosition(3)+2*object.HorizontalMargin;
        switch lower(master.TabLocation)
            case {'left' 'right'}
                width=width+object.HorizontalMargin;
        end
        DialogPosition(3)=max(MasterPosition(3),width);
        height=DialogPosition(4)+2*object.VerticalMargin;
        switch lower(master.TabLocation)
            case {'top' 'bottom'}
                height=height+object.VerticalMargin;
        end        
        DialogPosition(4)=max(MasterPosition(4),height);
        try
            master.InnerPosition(3:4)=DialogPosition(3:4);
        catch
            master.Position(3:4)=DialogPosition(3:4);
        end
        set(master,'Units',units);
end

% manage output
if nargout > 0
    varargout{1}=new;
end

end