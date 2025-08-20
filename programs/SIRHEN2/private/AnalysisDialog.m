function varargout=AnalysisDialog()

% create dialog
setProgramFont()
dlg=SMASH.MUI.Dialog();
dlg.Name='Spectrogram';
dlg.Hidden=true;

h=addblock(dlg,'button','FFT options',20);
set(h,'Tag','FFToptions');

h=addblock(dlg,'table',{'Partition' ' '},[10 10],6);
set(h(1),'FontWeight','bold','String','Partition settings');
delete(h(2));
set(h(end),'ColumnEditable',[false true]);
data=get(h(end),'Data');
data{1,1}='Duration:';
data{2,1}='Advance:';
data{3,1}='Blocks:';
data{4,1}='Overlap:';
data{5,1}='Points:';
data{6,1}='Skip:';
set(h(end),'Data',data,'Tag','PartitionSettings');

list={};
list{end+1}='Update spectrogram';
list{end+1}='Manage ROI';
list{end+1}='Select reference';
list{end+1}='Generate history';
h=addblock(dlg,'list','Actions',list,20);
set(h(1),'FontWeight','bold');
set(h(2),'Tag','AnalysisActions','TooltipString','Double-click to perform action');

list={};
list{end+1}='Full history';
list{end+1}='Velocity';
list{end+1}='Amplitude';
list{end+1}='Spectrogram overlay';
h=addblock(dlg,'list','View',list,20);
set(h(1),'FontWeight','bold');
set(h(2),'Tag','ViewHistory');
set(h(2),'Enable','off');

% manage output
if nargout < 1
    show(dlg);
else
    varargout{1}=dlg;
end

end