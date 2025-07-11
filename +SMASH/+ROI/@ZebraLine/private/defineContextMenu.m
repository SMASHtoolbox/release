function hc=defineContextMenu(object)

hc=uicontextmenu;

uimenu(hc,'Label','Select color','Callback',@changeColor);
    function changeColor(varargin)
        new=uisetcolor();
        if numel(new) < 3
            return
        end
        object.Color=new;
    end

hm=uimenu(hc,'Label','Line width');
uimenu(hm,'Label','Thicker line','Callback',@makeLineThicker);
    function makeLineThicker(varargin)
        if object.LineWidth >= 0.5
            object.LineWidth=sqrt(2)*object.LineWidth;
        else
            object.LineWidth=0.5;
        end
    end
uimenu(hm,'Label','Thinner line','Callback',@makeLineThinner);
    function makeLineThinner(varargin)
        if object.LineWidth > 0.5
            object.LineWidth=object.LineWidth/sqrt(2);
        elseif object.MarkerSize > 0
            object.LineWidth=0;
        end
    end

hm=uimenu(hc,'Label','Marker size');
uimenu(hm,'Label','Larger marker','Callback',@makeMarkerLarger);
    function makeMarkerLarger(varargin)
        if object.MarkerSize >= 5
            object.MarkerSize=sqrt(2)*object.MarkerSize;
        else
            object.MarkerSize = 5;
        end
    end
uimenu(hm,'Label','Smaller smaller','Callback',@makeMarkerSmaller);
    function makeMarkerSmaller(varargin)
        if object.MarkerSize > 5
            object.MarkerSize=object.MarkerSize/sqrt(2);
        elseif object.LineWidth > 0
            object.MarkerSize=0;
        end
    end

end