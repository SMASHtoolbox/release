function toggle(object)

fig=object.Handle;
object.Pointer=get(fig,'Pointer');            
object.PointerShapeCData=get(fig,'PointerShapeCData');
object.WindowButtonDownFcn=get(fig,'WindowButtonDownFcn');
object.WindowButtonMotionFcn=set(fig,'WindowButtonMotionFcn');
object.WindowButtonUpFcn=set(fig,'WindowButtonUpFcn');
object.ButtonDownFcn=set(fig,'ButtonDownFcn');

end