% This class provides a basic colorbar for scaled images.  It works similar
% to the builtin "colorbar" function, but a simpler and more stable context
% menu is provided.
%    >> object=Colorbar(...);
%
% See also MUI
%

%
% created January 23, 2014 by Daniel Dolan (Sandia National Laboratories)
%
classdef Colorbar < handle
    properties (SetAccess=immutable)
        Handle % Graphic handle
    end
    methods (Hidden=true)
        function object=Colorbar(varargin)
            hc=colorbar(varargin{:});
            target=gca;
            for n=1:2:nargin
                if strcmp(varargin{n},'peer')
                    target=varargin{n+1};
                    break
                end
            end
            hm=uicontextmenu;%(ancestor(hc,'figure'));
            uimenu(hm,'Label','Adjust color scale',...
                'Callback',{@AdjustScale,hc});
            set(hc,'UIContextMenu',hm);
            setappdata(hc,'TargetAxes',target);
            setappdata(hc,'AdjustScaleDialog',[]);
            set(hc,'DeleteFcn',@DeleteColorbar)
            function DeleteColorbar(varargin)
                fig=getappdata(hc,'AdjustScaleDialog');
                if ishandle(fig)
                    delete(fig)
                end
            end           
            object.Handle=hc;
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

CurrentMap=colormap(haxes);
MapList={'(current)' 'jet' 'parula' 'gray' 'reverse gray' 'cool/warm'};
SelectMap=addblock(dlg,'popup','Color map:',MapList,20);
set(SelectMap(end),'Callback',@changeColorMap)
    function changeColorMap(varargin)
        value=get(varargin{1},'Value');       
        switch MapList{value}
            case '(current)'
                map=CurrentMap;                
            case 'jet'
                map=jet();
            case 'parula'
                map=parula();
            case 'gray'
                map=gray();
            case 'reverse gray'
                map=gray();
                map=map(end:-1:1,:);
            case 'cool/warm'
                map=SMASH.MUI.Colormap.coolwarm();
        end
        colormap(haxes,map);
    end

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
        temp=sscanf(value{2},'%g',1);
        if ~isempty(temp)
            current(1)=temp;
        end
        temp=sscanf(value{3},'%g',1);
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