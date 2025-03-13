function varargout=NameDialog()

% create dialog
setProgramFont()
dlg=SMASH.MUI.Dialog();
dlg.Name='Name';
dlg.Hidden=true;

%h=addblock(dlg,'button',{'Name:' '' 'Comment'},20);
%h=addblock(dlg,'edit_button',{'Name:' 'Comment'},20);
h=addblock(dlg,'custom',{'text' 'edit' 'button'},{'Name: ' repmat(' ',[1 20]) 'Comments'});
delete(h(2)); % unused label
h=h([1 3 4]);
set(h(1),'FontWeight','bold');
set(h(2),'Tag','MeasurementName');
set(h(3),'Tag','MeasurementComments');
posA=getpixelposition(h(1));
posB=getpixelposition(h(2));
y0=posB(2)+(posB(2)+posB(4))/2;
posA(2)=y0-posB(4)/2;
posA(1)=posB(1)-posA(3);
setpixelposition(h(1),posA);

% manage output
if nargout < 1
    show(dlg);
else
    varargout{1}=dlg;
end

end