function CancelWait(src,varargin)

fig=ancestor(src,'figure');
object=getappdata(fig,'Object');
object.Cancel=true;
delete(object.Handle);

end