% HandleFinder : Locate common handles in PointVISARGUI

function func=HandleFinder()

func=[];

tag='PointVISARGUI';
func=setfield(func,tag,findobj('Tag',tag));

tag='LoadSignalsGUI';
func=setfield(func,tag,findobj('Tag',tag));

tag='ParamsGUI';
func=setfield(func,tag,findobj('Tag',tag));

tag='RecordListBox';
func=setfield(func,tag,findobj('Tag',tag));

tag='SignalPlotAxes';
func=setfield(func,tag,findobj('Tag',tag));

tag='FilterGUI';
func=setfield(func,tag,findobj('Tag',tag));

tag='EllipseGUI';
func=setfield(func,tag,findobj('Tag',tag));

tag='FringesGUI';
func=setfield(func,tag,findobj('Tag',tag));

tag='SaveSignalsGUI';
func=setfield(func,tag,findobj('Tag',tag));