function destroy(object,~)

parent=ancestor(object,'figure');
fig=findall(0,'Type','figure');
for k=1:numel(fig)
    h=getappdata(fig(k),'SourceFigure');
    if isempty(h)
        continue
    elseif parent==h
        delete(fig(k));
    end    
end


end