function enableControl(control)

set([control.LinkOffsets control.ChannelSettings control.ChannelActions],...
    'Enable','on');
set([control.MeasurementName control.MeasurementComments],'Enable','on');

set([control.FFToptions],'Enable','on');
set([control.PartitionSettings control.AnalysisActions],'Enable','on');

end