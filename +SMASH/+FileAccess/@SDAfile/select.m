% select Select record from an archive
%
% This method allows users to browse and select a record from an archive
% file. 
%    >> choice=select(archive,[pattern],[reference]);
% A dialog box lists the label, type, and description for
% records found in the archive.  Record choice can be restricted with an
% optional text search pattern; all existing records are displayed by
% default.  The optional "reference" input specifies how the dialog box is
% positioned.  The dialog box is normally centered on the primary display,
% but the dialog can also be centered on an exiting figure by passing its
% graphical handle.
%
% Pressing the "OK" button returns the user's selection as a character
% array.  Closing the dialog or pressing the "cancel" button returns an
% empty array.
%
% See also SDAfile, probe
%

%
% created October 9, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function choice=select(archive,pattern,reference)

% handle input
if (nargin<2) || isempty(pattern)
    pattern='';
end

if (nargin<3) || isempty(reference)
    reference=0;
end

% display archive contents
[label,type,description]=probe(archive,pattern);
if numel(label)==1
    choice=label{1};
    return
end

dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Archive contents';

htitle=addblock(dlg,'text','Archive contents');
set(htitle,'FontWeight','bold');

hlabel=addblock(dlg,'popup','Label:',label,20);
set(hlabel(end),'Callback',@update)
    function update(varargin)
        choice=get(hlabel(end),'Value');
        %set(htype(end),'String',type{choice});
        set(htype,'String',sprintf('Type: %s',type{choice}));
        temp=textwrap(hdescription(end),{description{choice}});
        set(hdescription(end),'String',temp);        
    end

htemp=addblock(dlg,'text','M');
width=cellfun(@numel,type);
width=max(width);
htype=addblock(dlg,'text','Type:',width);
%set(htype(end),'Style','text');
%matchParent(htype(end));
delete(htemp);

hdescription=addblock(dlg,'medit','Description:',40,3);

hbutton=addblock(dlg,'button',{'OK','cancel'});
set(hbutton(1),'Callback','delete(gcbo)');
set(hbutton(2),'Callback','delete(gcbf)');

update;
locate(dlg,'center',reference);
dlg.Hidden=false;
dlg.Modal=true;
waitfor(hbutton(1));

if isvalid(dlg) && ishandle(dlg.Handle)
    choice=label{choice};
    delete(dlg);
else
    choice=0;
end

end

function matchParent(h)

parent=get(h,'Parent');
switch get(parent,'Type')
    case 'figure'
        color=get(parent,'Color');
    otherwise
        color=get(parent,'BackgroundColor');
end
set(h,'BackgroundColor',color);

end