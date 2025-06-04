function tightscale(object,mode)

switch mode
    case 'create'
        h=uitoggletool('Parent',object.ToolBar,...
            'Tag','TightScale','ToolTipString','Tight scale',...
            'Cdata',local_graphic('TightScaleIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.TightScale=h;
    case 'hide'
        set(object.Button.TightScale,'Visible','off');
    case 'show'
        set(object.Button.TightScale,'Visible','on');
end

%%
    function callback(src,varargin)
        state=get(src,'State');
        detoggle(object);
        fig=object.Handle;
        if strcmpi(state,'on')
            haxes=findobj(fig,'Type','axes');
            if numel(haxes)==1
                axis(haxes,'tight');
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
            axis(haxes(k),'tight');
        end                
    end

end