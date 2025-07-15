%    loadImage(object);
%    loadImage(object,filename);
function loadImage(object,file)

% manage input
if (nargin < 2) || isempty(file)
    list={'*.png;*.PNG;*.jpg;*.JPG;*.tif;*.TIF;*.tiff;*.TIFF' ...
        'Supported graphic files'};
    [file,location]=uigetfile(list,'Select graphic file');
    if isnumeric(file)
        return
    end
    file=fullfile(location,file);
else
    assert(ischar(file) && logical(exist(file,'file')),...
        'ERROR: invalid image file');
end

% read image
try
    [object.Image,object.ColorMap]=imread(file);
catch ME
    throwAsCaller(ME);
end

[~,file,ext]=fileparts(file);
object.ImageFile=[file ext];

if size(object.Image,3) > 3
    object.Image=object.Image(:,:,1:3);
end


end