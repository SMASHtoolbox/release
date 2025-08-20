%
% created April 2, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function dump(object,mode)

switch mode
    case 'create'
        h=uipushtool('Parent',object.ToolBar,...
            'Tag','Dump','ToolTipString','Dump plots',...
            'Cdata',local_graphic('DumpIcon'),'Separator','off',...
            'ClickedCallback',@callback);
        object.ToolButton.Dump=h;
    case 'hide'
        set(object.Button.Dump,'Visible','off');
    case 'show'
        set(object.Button.Dump,'Visible','on');
end

    function callback(varargin)        
        location=sprintf('%.0f-',datevec(now));
        location=sprintf('PlotDump_%s',location(1:end-1));
        location=fullfile(pwd,location);
        %
        ha=findobj(object.Handle,'Type','axes','Visible','on');
        ha=ha(end:-1:1);
        for n=1:numel(ha)
            if n == 1
                mkdir(location);
            end
            pos=getpixelposition(ha(n));
            pos(1:2)=0;
            fig=figure('Visible','off','Units','pixels');
            if pos(3) > pos(4)
                fig.PaperOrientation='landscape';
            else
                fig.PaperOrientation='portrait';
            end
            fig.Units=fig.PaperUnits;
            fig.Position=fig.PaperPosition;
            new=copyobj(ha(n),fig);                        
            set(new,'Units','normalized','OuterPosition',[0 0 1 1]);
            file=fullfile(location,sprintf('plot%d.pdf',n));
            print(fig,'-dpdf',file);
            delete(fig);
        end
        
    end
end