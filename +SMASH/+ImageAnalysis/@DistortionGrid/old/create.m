function object=create(object,varargin)

object=create@SMASH.ImageAnalysis.Image(object,varargin{:});
object.Name='Distortion object';
object.GraphicOptions.Title='Distortion object';

end