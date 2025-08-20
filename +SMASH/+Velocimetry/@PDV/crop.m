% crop Crop time range
%
% This method crops PDV channels to a specified time range.
%    object=crop(object,[start stop]);
%
% When no range is specified:
%    object=crop(object);
% the user is prompted to select a crop region.  Passing graphic handles:
%    object=crop(object,target);
% uses existing axes targets for interactive selection.
%
% See also PDV
%

%
% created February 9, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=crop(object,bound)

% manage input
if (nargin < 2)
    [~,target]=view(object,'spectrogram');
    fig=gcf;
    region=SMASH.ROI.Rectangle('x');   
    region.Name='Crop region ';
    region=select(region,target);
    bound=region.Data;
    delete(fig);
elseif all(ishandle(bound))
    region=SMASH.ROI.Rectangle('x');
    region.Name='Crop region ';
    region=select(region,bound);
    bound=region.Data;
else
    errmsg='ERROR: invalid crop bound(s)';
    assert(isnumeric(bound) && numel(bound) == 2,errmsg);
    bound=sort(bound);
    assert(diff(bound) > 0,errmsg);    
end   

% attempt crop
ReferenceLost=false;
tref=object.ReferenceSelection;
for n=1:object.NumberChannels
    object.Channel{n}.Measurement=crop(object.Channel{n}.Measurement,bound);
    t=object.Channel{n}.Measurement.Grid;
    if isempty(tref)
        % do nothing
    elseif all(tref < t(1)) || all(tref > t(end))
        ReferenceLost=true;
    end
    if ~isempty(object.PrivateSpectrogram)
        object.PrivateSpectrogram{n}=crop(object.PrivateSpectrogram{n},bound,[]);
    end
end
if ~isempty(object.PrivateSpectrogram)
    object.SpectrogramSettings.Partition.Blocks=...
        numel(object.PrivateSpectrogram{1}.Grid1);
    object=partition(object,'Points',...
        [object.Partition.Points object.Partition.Skip]);
end

% update status
object=changeStatus(object,'obsolete','History');

if ReferenceLost
    object.ReferenceSelection=[];
    object.Status.Reference='incomplete';
    warning('Reference selection lost by cropping');
end
   
end