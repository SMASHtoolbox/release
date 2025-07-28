% This method fills in the Settings and Results property during object
% creation
function object=create(object)

% general set up
object.Measurement.GraphicOptions.Title='Step wedge';

% set up settings structure
settings=struct();
  
settings.ID='AI-11-0004';

settings.StepLevels = [0.08 0.20 0.35 0.51 0.64 0.78 0.94 ...
            1.12 1.25 1.39 1.54 1.67 1.82 1.98 ...
            2.15 2.29 2.43 2.59 2.76 2.91 3.02];
settings.StepOffsets = [0 2];

settings.DerivativeParams= [1 9]; % [order nhood]
settings.HorizontalMargin=0.20; % fractional
settings.VerticalMargin=0.10; % fraction

object.Settings=settings;

% set up results structure
results=struct();
results.RegionTable=[]; % Region of interest table ([x0 y0 Lx Ly])
results.TransferTable=[];
results.TransferPoints=[];

object.Results=results;

end