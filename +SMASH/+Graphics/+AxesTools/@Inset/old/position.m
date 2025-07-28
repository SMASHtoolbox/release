% position Position inset rectancle and axes
%
% This method manually positions the inset rectangle and axes.
%    position(object);
% Positioning is controlled through a modal dialog box
%
% See also AxesInset
%

%
% created January 19, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function position(object)

% launch dialog box
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Position inset';

% rectangle bounds
h=addblock(dlg,'edit','Horizontal bound (axes units):',20);
temp=sprintf('%.6g %.6g',object.XBound);
set(h(end),'Callback',@readBound,...
    'String',temp,'UserData',temp);
h=addblock(dlg,'edit','Vertical bound (axes units):',20);
temp=sprintf('%.6g %.6g',object.YBound);
set(h(end),'Callback',@readBound,...
    'String',temp,'UserData',temp);
    function readBound(src,~)
        temp=get(src,'String');
        [temp,count]=sscanf(temp,'%g',2);
        if count == 2
            temp=sort(temp);
            temp=sprintf('%.6g ',temp);
        else            
            temp=get(src,'UserData');
        end
        set(src,'String',temp);
    end

% inset position
h=addblock(dlg,'edit','Inset position (normalized units):',20);
temp=sprintf('%.6g %.6g %.6g %.6g',object.Position);
set(h(end),'Callback',@readPosition,...
    'String',temp,'UserData',temp);
    function readPosition(src,~)
        temp=get(src,'String');
        [temp,count]=sscanf(temp,'%g');
        if count == 4    
            temp=sprintf('%.6g ',temp);
        else            
            temp=get(src,'UserData');
        end
        set(src,'String',temp);
    end

h=addblock(dlg,'button',{' Apply ' ' Done '});
set(h(1),'Callback',@apply);
    function apply(varargin)
        data=probe(dlg);
        object.XBound=sscanf(data{1},'%g');
        object.YBound=sscanf(data{2},'%g');
        object.Position=sscanf(data{3},'%g');
        update(object);
    end
set(h(2),'Callback',@done);
    function done(varargin)
        delete(dlg);
    end

fig=ancestor(object.Source,'figure');
locate(dlg,'center',fig);
dlg.Hidden=false;
dlg.Modal=true;

end