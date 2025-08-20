function export(object,mode)

switch mode
    case 'create'
        h=uipushtool('Parent',object.ToolBar,'Tag','saveas',...
            'ToolTipString','Export figure',...
            'CData',local_graphic('SaveIcon'),...
            'ClickedCallback',{@callback,object});
        object.ToolButton.SaveAS=h;
    case 'hide'
        set(object.Button.SaveAs,'Visible','off');
    case 'show'
        set(object.Button.SaveAs,'Visible','on');
end

end
%%
function callback(~,~,fig)

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Export figure';

name=addblock(dlg,'edit_button',{'Filename:','select'},20);
set(name(end),'Callback',@selectFile);
    function selectFile(varargin)
        switch get(filetype(2),'Value')
            case 1
                filterspec={'*.eps;*.EPS','*.eps files'};               
            case 2
                filterspec={'*.fig;*.FIG','*.fig files'};
            case 3
                filterspec={'*.jpg;*.JPG','*.jpg files'};
            case 4
                filterspec={'*.png;*.PNG','*.png files'};
            case 5
                filterspec={'*.tif;*.TIF;*.tiff;*.TIFF','*.tif files'};
        end
        [filename,pathname]=uiputfile(filterspec,'Select file');
        if isnumeric(filename)
            return
        end
        filename=fullfile(pathname,filename);
        set(name(2),'String',filename);
    end

choices={'EPS','JPG','PDF','PNG','TIF'};
filetype=addblock(dlg,'popup','File type',choices);
set(filetype(2),'Value',3);

choices={'75 DPI','150 DPI','300 DPI','600 DPI'};
resolution=addblock(dlg,'popup','Resolution:',choices);
set(resolution(2),'Value',2);

button=addblock(dlg,'buttons',{'OK','cancel'});
set(button(1),'Callback',@okCallback);
    function okCallback(varargin)
        data=probe(dlg);
        filename=data{1};
        filetype=data{2};
        switch filetype
            case 'EPS'
                device='-depsc';
            case 'JPEG'
                device='-djpeg100';
            case 'PDF'
                device='-dpdf';
                Units=get(fig.Handle,'Units');
                PaperUnits=get(fig.Handle,'PaperUnits');
                set(fig.Handle,'Units','inches','PaperUnits','inches');
                position=get(fig.Handle,'Position');
                set(fig.Handle,'PaperSize',position(3:4));
                set(fig.Handle,'Units',Units,'PaperUnits',PaperUnits);
            case 'PNG'
                device='-dpng';
            case 'TIFF'
                device='-dtiff';
        end
        resolution=sscanf(data{3},'%g',1);
        resolution=sprintf('-r%d',resolution);
        try
            old=get(fig.Handle,'PaperPositionMode');
            set(fig.Handle,'PaperPositionMode','auto');
            print(fig.Handle,device,resolution,filename);
            set(fig.Handle,'PaperPositionMode',old);
        catch
            set(fig.Handle,'PaperPositionMode',old);
            error('ERROR: unable to create file');
        end       
        close(gcbf);
    end
set(button(2),'Callback','close(gcbf)');

locate(dlg,'center',fig.Handle);
set(dlg.Handle,'HandleVisibility','callback');
dlg.Hidden=false;
uiwait(dlg.Handle);

end