% VIEW ImageGroup visualization
%
% This method provides several types of visualization for ImageGroup objects.
% By default:
%    >> view(object);
% the objected is displayed as a mosaic of images in a new figure; a graphic
% handle can be passed to render the image in a specific location.
%    >> view(object,mode,gca); % show in current axes
% The standard view shows the image with a colorbar and uses labels
% specified in the object.
%
% A single image from the group can be selected
% by passing that image number in the 'mode' field.
%    >> view(object,imageNumber); % create new figure
%    >> view(object,imageNumber,fig); % draw in exiting figure
% The detail region can be moved by clicking on the full image or by
% pressing the direction keys.  To change the size of this region, press a
% direction key while holding down the shift key.
%
%
% In all cases, graphic handles created by the method are
% returned as a structure.
%    >> h=view(...);
% 
% See also ImageGroup

%
% created November 25 2013 by Daniel Dolan (Sandia National Laboratories)
% created January 28, 2016 by Sean Grant (Sandia Natinal Laboratories/UT)
%
%function varargout=view(object,mode,varargin)
function varargout=view(object,mode,target)

% verify uniform grid
object=makeGridUniform(object);

% handle input
frameNumber=1;
if (nargin<2) || isempty(mode)
    mode='mosaic';
elseif isnumeric(mode)
    frameNumber=mode;
    mode='single';
end

assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'mosaic','single','snapshot','show','full color'}
        % do nothing
    otherwise
        error('ERROR: invalid view mode');
end

if nargin<3
    target=[];
end

% call the appropriate method
if ~isreal(object.Data)
    assert(strcmp(mode,'show'),'ERROR: %s mode requires real Data',mode);
    object.DataScale='linear';
    object.DataLim='auto';
    name=object.GraphicOptions.Title;
    data=object.Data;
    h=basic_figure;
    set(h.figure,'Name','Complex Image view');
    ha(1)=subplot(1,2,1);
    object.Data=real(data);   
    object.GraphicOptions.Title=sprintf('Real part of "%s"',name);
    show(object,ha(1));
    ha(2)=subplot(1,2,2);
    object.Data=imag(data);
    object.GraphicOptions.Title=sprintf('Imaginary part of "%s"',name);
    show(object,ha(2));   
    linkaxes(ha,'xy');
elseif strcmp(mode,'mosaic')
        h=showMosaic(object,target);
elseif strcmp(mode,'single') || strcmp(mode,'show')
        h=showSingle(object,frameNumber,target);
elseif strcmp(mode,'snapshot')
        h=showSnapshot(object,target);   
elseif strcmp(mode,'full color')
        h=showFullColor(object,target);
end

% handle output
if nargout>=1
    varargout{1}=h;
end

end