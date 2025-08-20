function aboutSIRHEN(varargin)

parent=gcbf();

dlg=findall(groot,'Type','figure','Tag','aboutSIRHEN');
if ~isempty(dlg)
    delete(dlg);
end
dlg=SMASH.MUI.Dialog();
dlg.Hidden=true;
dlg.Name='About SIRHEN';

addblock(dlg,'text',{'SIRHEN 2.0' 'May 2023'});

locate(dlg,'center',parent);
dlg.Hidden=false;

set(dlg.Handle,'Tag','aboutSIRHEN','HandleVisibility','callback');

end