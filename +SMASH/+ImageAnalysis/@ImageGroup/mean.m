% MEAN Calculate mean Data value(s)
%
% This method calculates the mean Data value for ImageGroup objects.  Averaging
% can be performed over a specified coordinate ('Grid1' or 'Grid2'):
%    >> result=mean(object,coordinate);
% or over the limited region.
%    >> value=mean(object,'Region');
% In the former case, "result" is a SignalGroup object, which has its own set of
% processing and visualization methods. In the latter case, the result is a
% Signal object with each Image providing one data point.
%
% Grid boundaries can be defined with an additional input:
%    >> result=mean(object,'Grid1',[xmin xmax]);
%    >> result=mean(object,'Grid2',[ymin ymax]);
%    >> result=mean(object,'Region',[xmin xmax],[ymin ymax]);
% These calls override the object's limited region settings.
%
% WARNING: NaN values in an Image can cause unexpected results!  These
% values are often used as placeholders after certain image operations,
% such as rotation.  NaN values need to be removed/excluded for this
% method to function correctly.
%
% see also ImageGroup, slice, SignalAnalysis.SignalGroup, SignalAnalysis.SignalGroup

% created January 29, 2016 by Sean Grant (Sandia National Laboratories/UT)

function varargout=mean(object,coordinate,varargin)

% handle input
if (nargin<2) || isempty(coordinate)
    coordinate=questdlg('Select mean type','Mean type',...
        ' Grid1 ',' Grid2 ',' Region ',' Grid1 ');
    coordinate=strtrim(coordinate);
    if isempty(coordinate)
        return
    end
end

% split up ImageGroup
temp=cell(object.NumberImages,1);
tempObj=cell(object.NumberImages,1);

% Perform function on each image individually
switch lower(coordinate)
    case 'grid1'
        [temp{:}]=split(object);
        for n=1:object.NumberImages
            tempObj{n}=mean(temp{n},coordinate,varargin{:});
        end
        
        % make SignalGroup from individual Signals
        result=SMASH.SignalAnalysis.SignalGroup(tempObj{:});
    case 'grid2'
        [temp{:}]=split(object);
        for n=1:object.NumberImages
            tempObj{n}=mean(temp{n},coordinate,varargin{:});
        end
        
        % make SignalGroup from individual Signals
        result=SMASH.SignalAnalysis.SignalGroup(tempObj{:});
    case 'region'
        [temp{:}]=split(object);
        data=zeros(object.NumberImages,1);
        for n=1:object.NumberImages
            tempObj{n}=mean(temp{n},coordinate,varargin{:});
            data(n)=tempObj{n}.Data;
        end
        
        % make Signal from individual Data values
        grid=(1:object.NumberImages);
        result=SMASH.SignalAnalysis.Signal(grid,data(:));
        name=sprintf('Region mean of "%s"',object.Name);
        result.Name=name;
        result.GraphicOptions.Title=name;
        result.GridLabel='Image Number';
        result.DataLabel='Mean Value';
        result.Source='ImageGroup Mean operation';
    otherwise
        error('ERROR: %s is not a valid coordinate',coordinate);
end
        

% handle outputs
if nargout==0
    view(result);
end

if nargout==1
    varargout{1}=result;    
end

end

