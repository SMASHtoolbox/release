% This method fills in the Settings and Results property during object
% creation
function object=create(object)

% general set up
object.Measurement.GraphicOptions.Title='Distortion grid';

% % set up settings structure
% settings=struct();
% 
% settings.ID=object.DefaultID;
% 
% settings.StepLevels = object.DefaultStepLevels;
% settings.StepOffsets = object.DefaultStepOffsets;
% 
% settings.DerivativeParams= object.DefaultDerivativeParams; % [order nhood]
% settings.HorizontalMargin=object.DefaultHorizontalMargin; % fractional
% settings.VerticalMargin=object.DefaultVerticalMargin; % fraction
% 
% settings.AnalysisRange=object.DefaultAnalysisRange; % [min max] (fractional)
% settings.PolynomialOrder=object.DefaultPolynomialOrder; % polynomial fit order
% 
% object.Settings=settings;
% 
% % set up results structure
% results=struct();
% results.RegionTable=[]; % Region of interest table ([x0 y0 Lx Ly])
% results.TransferTable=[];
% results.TransferPoints=[];
% 
% object.Results=results;

end