function hc=basic_colorbar(varargin)

% create colorbar
hc=colorbar(varargin{:});

% modify colorbar
hm=uicontextmenu;
uimenu(hm,'Label','Adjust color scale','Callback',{@AdjustScale,hc});

set(hc,'UIContextMenu',hm);
setappdata(hc,'TargetAxes',[]);
setappdata(hc,'AdjustScaleDialog',[]);

% finish up
set(hc,'DeleteFcn',@DeleteColorbar)
    function DeleteColorbar(varargin)
        fig=getappdata(hc,'AdjustScaleDialog');
        if ishandle(fig)
            delete(fig)
        end
    end

end

function AdjustScale(varargin)

hc=varargin{3};
haxes=getappdata(hc,'TargetAxes');
current=get(haxes,'CLim');

fig=getappdata(hc,'AdjustScaleDialog');
if ishandle(fig)
    figure(fig);
    return
end

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Color scale';
h=addblock(dlg,'text','Set color scale',20);
set(h,'FontWeight','bold');
h=addblock(dlg,'edit',{'Minimum:'});
MinEdit=h(2);
set(MinEdit,'String',sprintf('%g',current(1)));
h=addblock(dlg,'edit',{'Maximum:'});
MaxEdit=h(2);
set(MaxEdit,'String',sprintf('%g',current(2)));

h=addblock(dlg,'button',{'Auto scale'});
set(h(1),'Callback',@AutoScale);
    function AutoScale(varargin)
        set(haxes,'CLimMode','auto');
        current=get(haxes,'CLim');
        set(MinEdit,'String',sprintf('%g',current(1)));
        set(MaxEdit,'String',sprintf('%g',current(2)));
    end

h=addblock(dlg,'button',{' Apply ',' Done '});
set(h(1),'Callback',@Apply);
set(h(2),'Callback',@Done);
    function Apply(varargin)
        current=get(haxes,'CLim');
        value=probe(dlg);
        temp=sscanf(value{1},'%g',1);
        if ~isempty(temp)
            current(1)=temp;   
        end
        temp=sscanf(value{2},'%g',1);
        if ~isempty(temp)
            current(2)=temp;   
        end
        set(haxes,'CLim',current);
    end
    function Done(varargin)
        delete(dlg);
    end

locate(dlg,'southwest',ancestor(haxes,'figure'));
dlg.Hidden=false;
setappdata(hc,'AdjustScaleDialog',dlg.Handle);

end