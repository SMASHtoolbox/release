function object=import(object,varargin)

object=import@SMASH.SignalAnalysis.Signal(object,varargin{:});

object.Name='ShortTime object';
object.GraphicOptions.Title='ShortTime object';
object.GridLabel='Time';
object.DataLabel='Signal';

end