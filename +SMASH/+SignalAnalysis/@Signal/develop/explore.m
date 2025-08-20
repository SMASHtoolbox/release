% EXPLORE Interactive object exploration
%
% This method displays signal objects in an figure that
% provides interactive manipulation.
%    >> explore(object); 
%
% See also Signal, conv, crop, limit, locate, map, scale, shift,
% smooth, store, transform, view
%

% created October 5, 2013 by Daniel Dolan (Sandia National Laboratories) 
function explore(object)

%% create figure
name=sprintf('Explore "%s"',object.GraphicOptions.Title);
set(fig.Handle,'Name',name);

ha(1)=axes('Parent',fig.Handle,'Tag','FullPlot',...
    'Units','normalized','OuterPosition',[0 0.5 1 0.5]);
index=object.LimitIndex;
object=limit(object,'all');
view(object,'Parent',ha(1));
xlabel(ha(1),object.GridLabel);
ylabel(ha(1),object.DataLabel);
title('Full range');

object=limit(object,'Index',index);
ha(2)=axes('Parent',fig.Handle,'Tag','LimitedPlot',...
    'Units','normalized','OuterPosition',[0 0. 1 0.5]);
view(object,'Parent',ha(2));
xlabel(ha(2),object.GridLabel);
ylabel(ha(2),object.DataLabel);
title('Limited range');

set(ha,'Box','on','XLimMode','auto','YLimMode','auto');

%% create Signal menu
hm=uimenu(fig.Handle,'Label','Signal');
uimenu(hm,'Label','Crop','Callback',@CropSignal);    

uimenu(hm,'Label','Limit');
uimenu(hm,'Label','Store');
uimenu(hm,'Label','Export');
%uimenu(hm,'Label','Close');

%% create Grid menu
hm=uimenu(fig.Handle,'Label','Grid');
uimenu(hm,'Label','Shift');
uimenu(hm,'Label','Scale');
uimenu(hm,'Label','Label');

%% create Data menu
hm=uimenu(fig.Handle,'Label','Data');
uimenu(hm,'Label','Map');
uimenu(hm,'Label','Smooth');
uimenu(hm,'Label','Label');

% create Analyze menu
hm=uimenu(fig.Handle,'Label','Analyze');
uimenu(hm,'Label','Calculate power spectrum');
uimenu(hm,'Label','Locate feature');

end

%% utilities
function h=FindOrCreate(src,name)
if isappdata(src,name)
    h=getappdata(src,name);
    if ishandle(h)
        figure(h)
        return
    end
end
MUI=module('uplevel=1','MUI');
h=call(MUI,'Dialog');
setappdata(src,name,h.Handle);
end

%%
function CropSignal(src,varargin)     

% see if dialog already exists
dlg=FindOrCreate(src,'CropDialog');
if ishandle(dlg)
    return
end

% fill out new dialog box
fig=ancestor(src,'figure');
dlg.Hidden=true;
dlg.Name='Crop Signal';

left=addblock(dlg,'edit','Left boundary: ');
right=addblock(dlg,'edit','Right boundary:');
full=addblock(dlg,'buttons','  Full plot   ');
set(full,'Callback',@DetectFull);
    function DetectFull(varargin)
        h=findobj(fig,'Tag','FullPlot');
        xb=get(h,'XLim');
        set(left(end),'String',sprintf('%#+g',xb(1)));
        set(right(end),'String',sprintf('%#+g',xb(2)));
    end

addblock(dlg,'buttons',' Limited plot ');
addblock(dlg,'buttons',{'Apply','Done'});
dlg.Hidden=false;
end
