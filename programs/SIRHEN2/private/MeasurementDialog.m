function varargout=MeasurementDialog()


% create dialog
setProgramFont()
dlg=SMASH.MUI.Dialog();
dlg.Name='PDV measurement';
dlg.Hidden=true;

%
h=addblock(dlg,'button','Load data',20);
set(h(1),'Tag','LoadChannel');

h=addblock(dlg,'list','Channels',{' '},10,3);
set(h(1),'FontWeight','bold');
set(h(2),'Tag','ChannelList','String',{});


h=addblock(dlg,'table',{' ' ' '},[10 10],4);
set(h(1),'FontWeight','bold','String','Settings');
set(h(end),'ColumnEditable',[false true]);
data=get(h(end),'Data');
data{1,1}='Wavelength:';
data{2,1}='Offset:';
data{3,1}='Bandwidth:';
data{4,1}='Correction:';
set(h(end),'Data',data,'Tag','ChannelSettings');

h=addblock(dlg,'checkbox','Link offsets');
set(h,'Tag','LinkOffsets');

temp={' '};
temp=repmat(temp,[1 4]);
h=addblock(dlg,'list','Actions',temp,20);
set(h(1),'FontWeight','bold');
list={};
list{end+1}='Shift time base';
list{end+1}='Scale time base';
list{end+1}='Crop time base';
list{end+1}='Calculate offset';
list{end+1}='Remove sinusoid';
list{end+1}='Show raw spectrogram(s)';
list{end+1}='Show signal(s)';
set(h(2),'Tag','ChannelActions','String',list,...
    'TooltipString','Double-click to perform action');

% manage output
if nargout < 1
    show(dlg);
else
    varargout{1}=dlg;
end

end