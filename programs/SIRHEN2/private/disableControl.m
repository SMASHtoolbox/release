function disableControl(control)

set([control.LinkOffsets control.ChannelSettings control.ChannelActions],...
    'Enable','off');
set([control.MeasurementName control.MeasurementComments],'Enable','off');

set([control.FFToptions],'Enable','off');
set([control.PartitionSettings control.AnalysisActions],'Enable','off');

end