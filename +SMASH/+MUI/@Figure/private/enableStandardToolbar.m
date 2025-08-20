function enableStandardToolbar(object)

hc=uicontextmenu;

label={'Show standard toolbar' 'Hide standard toolbar'};
hide=true;
hsub(1)=uimenu(hc,'Label',label{1},'Callback',@changeVisibility);
    function changeVisibility(varargin)
        if hide
            set(object.Handle,'Toolbar','figure');
            set(hsub(1),'Label',label{2});
            hide=false;
        else
            set(object.Handle,'Toolbar','none');
            set(hsub(1),'Label',label{1});
            hide=true;
        end
    end

set(object.ToolBar,'UIContextMenu',hc);

end