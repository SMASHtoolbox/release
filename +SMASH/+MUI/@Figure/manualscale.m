function manualscale(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','ManualScale','ToolTipString','Manual scale',...
            'Cdata',local_graphic('ManualScaleIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.ManualScale=h;
    case 'hide'
        set(object.Button.ManualScale,'Visible','off');
    case 'show'
        set(object.Button.ManualScale,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        fig=object.Handle;
        if strcmpi(state,'on')
            haxes=findobj(fig,'Type','axes');
            if numel(haxes)==1
                MakeDialog(haxes);
                return
            end
            set(src,'State','on');
            set(object.Handle,'Pointer','crosshair',...
                'WindowButtonUpFcn',@ButtonUp);
        end
    end

%%
    function ButtonUp(varargin)
        haxes=get(gcbf,'CurrentAxes');
        tag=get(haxes,'Tag');
        if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
            return
        end
        MakeDialog(haxes);
    end

end

%%
function MakeDialog(target)

% create dialog
dlg=getappdata(gcbf,'ManualScalingDialog');
if ~isempty(dlg)
    delete(dlg);
end
dlg=SMASH.MUI.Dialog();
setappdata(gcbf,'ManualScalingDialog',dlg);
dlg.Hidden=true;
dlg.Name='Manual scaling';


xb=get(target,'XLim');
hmin=addblock(dlg,'edit','Horizontal min:');
set(hmin(2),'String',sprintf('%#+.6g',xb(1)));
hmax=addblock(dlg,'edit','Horizontal max:');
set(hmax(2),'String',sprintf('%#+.6g',xb(2)));
hauto=addblock(dlg,'check','Auto scale');
set(hauto,'Callback',@AutoHorizontal);

yb=get(target,'YLim');
vmin=addblock(dlg,'edit','Vertical min:');
set(vmin(2),'String',sprintf('%#+.6g',yb(1)));
vmax=addblock(dlg,'edit','Vertical max:');
set(vmax(2),'String',sprintf('%#+.6g',yb(2)));
vauto=addblock(dlg,'check','Auto scale');
set(vauto,'Callback',@AutoVertical);

button=addblock(dlg,'button',{'Apply','Done'});
set(button(1),'Callback',@Apply);
set(button(2),'Callback',@Done);
locate(dlg,'center',ancestor(target,'figure'));
dlg.Hidden=false;

setappdata(dlg.Handle,'SourceFigure',gcbf);

% callbacks
    function AutoHorizontal(varargin)
        value=get(hauto,'Value');
        if value
            set(target,'XLimMode','auto');
            xb=get(target,'XLim');
            set(hmin(2),'String',sprintf('%#+.6g',xb(1)));
            set(hmax(2),'String',sprintf('%#+.6g',xb(2)));
            set([hmin(2) hmax(2)],'Enable','off');
        else
            set(target,'XLimMode','manual');
            set([hmin(2) hmax(2)],'Enable','on');
        end       
    end

    function AutoVertical(varargin)
        value=get(vauto,'Value');
        if value
            set(target,'YLimMode','auto');
            yb=get(target,'YLim');
            set(vmin(2),'String',sprintf('%#+.6g',yb(1)));
            set(vmax(2),'String',sprintf('%#+.6g',yb(2)));
            set([vmin(2) vmax(2)],'Enable','off');
        else
            set(target,'YLimMode','manual');
            set([vmin(2) vmax(2)],'Enable','on');
        end        
    end
    function Apply(varargin)
        xb=get(target,'XLim');
        yb=get(target,'YLim');
        value=probe(dlg);
        temp=sscanf(value{1},'%g',1);
        if ~isempty(temp)
            xb(1)=temp;
        end
        temp=sscanf(value{2},'%g',1);
        if ~isempty(temp)
            xb(2)=temp;
        end
        temp=sscanf(value{4},'%g',1);
        if ~isempty(temp)
            yb(1)=temp;
        end
        temp=sscanf(value{5},'%g',1);
        if ~isempty(temp)
            yb(2)=temp;
        end
        set(target,'XLim',sort(xb),'YLim',sort(yb));
    end
    function Done(varargin)
        delete(dlg);
    end

end