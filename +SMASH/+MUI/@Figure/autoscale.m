function autoscale(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','AutoScale','ToolTipString','Auto scale',...
            'Cdata',local_graphic('AutoScaleIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.AutoScale=h;
    case 'hide'
        set(object.Button.AutoScale,'Visible','off');
    case 'show'
        set(object.Button.AutoScale,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        fig=object.Handle;
        if strcmpi(state,'on')
            haxes=findobj(fig,'Type','axes');
            if numel(haxes)==1
                set(haxes,'XLimMode','auto','YLimMode','auto');
                return
            end
            set(src,'State','on');
            set(object.Handle,'Pointer','crosshair',...
                'WindowButtonUpFcn',@ButtonUp);
        end
    end

%%
    function ButtonUp(varargin)        
        selection=get(gcbf,'SelectionType');
        if strcmpi(selection,'extend')
            haxes=findobj(gcbf,'Type','axes');
            detoggle(object);
        else
            haxes=get(gcbf,'CurrentAxes');
        end        
        for k=1:numel(haxes)
            tag=get(haxes(k),'Tag');
            if  strcmp(tag,'legend') || strcmp(tag,'colorbar')
                return
            end
            set(haxes(k),'XLimMode','auto','YLimMode','auto');
        end                
    end

end