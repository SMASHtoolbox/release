% MEAN Calculate mean Data value(s)
%
% This method calculates the mean Data value for Image objects.  Averaging
% can be performed over a specified coordinate ('Grid1' or 'Grid2'):
%    >> result=mean(object,coordinate);
% or over the limited region.
%    >> value=mean(object,'Region');
% In the former case, "result" is a Signal object, which has its own set of
% processing and visualization methods.
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
% See also Image, slice, SignalAnalysis.Signal
%

%
% created November 25, 2013 by Daniel Dolan (Sandia National Laboratories)
% revised October 6, 2014 by Daniel Dolan
%    -added limit boundary override
% modified October 15, 2014 by Tommy Ao
%    -fixed trapz calculation to allow descending grids
function varargout=mean(object,coordinate,varargin)

% handle input
if (nargin<2) || isempty(coordinate)
    coordinate=questdlg('Select mean type','Mean type',...
        ' Grid1 ',' Grid2 ',' Region ',' Grid1 ');
    coordinate=strtrim(coordinate);
    %if strcmp(coordinate,'cancel')
    if isempty(coordinate)
        return
    end
end
switch lower(coordinate)
    case 'grid1'
        if numel(varargin)>=1
            object=limit(object,varargin{1},[]);
        end
    case 'grid2'
        if numel(varargin)>=1
            object=limit(object,[],varargin{1});
        end
    case 'region'        
        if numel(varargin)>=1
            object=limit(object,varargin{1},[]);
        end
        if numel(varargin)>=2
            object=limit(object,[],varargin{2});
        end        
    otherwise
        error('ERROR: %s is an invalid coordinate',coordinate);
end

% use integration to determine average value
[x,y,z]=limit(object);
switch lower(coordinate)
    case 'grid1'
        Grid=y;
        if numel(x)>1
%            Data=trapz(x,z,2)/(max(x)-min(x));
             Data=trapz(x,z,2)/(x(end)-x(1));
        else           
            Data=z;
        end
        name=sprintf('"%s" mean of "%s"',object.Grid1Label,object.Name);
        GridLabel=object.Grid2Label;
    case 'grid2'
        Grid=x;
        if numel(y)>1
%            Data=trapz(y,z,1)/(max(y)-min(y));
            Data=trapz(y,z,1)/(y(end)-y(1));
        else
            Data=z;
        end
        name=sprintf('"%s" mean of "%s"',object.Grid2Label,object.Name);
        GridLabel=object.Grid1Label;
    case 'region'
        Grid=nan;
        if numel(x)>1
%            Data=trapz(x,z,2)/(max(x)-min(x));
            Data=trapz(x,z,2)/(x(end)-x(1));
        else
            Data=z;
        end
        if numel(y)>1
%        Data=trapz(y,Data,1)/(max(y)-min(y));
        Data=trapz(y,Data,1)/(y(end)-y(1));
        else
            % do nothing
        end
        name=sprintf('Region mean of "%s"',object.Name);
        GridLabel='';
    otherwise
        error('ERROR: %s is not a valid coordinate',variable);
end
DataLabel=object.DataLabel;

% create Signal object to hold the results
result=SMASH.SignalAnalysis.Signal(Grid,Data);
result.Name=name;
result.GraphicOptions.Title=name;
result.GridLabel=GridLabel;
result.DataLabel=DataLabel;
result.Source='Image operation';

% handle output
if nargout==0
    if strcmpi(coordinate,'region')
        fprintf('Region mean = %g\n',result.Data);
    else
        view(result);
    end
end

if nargout==1
    varargout{1}=result;    
end

if nargout==2 % this mode is undocumented
    varargout{1}=Grid;
    varargout{2}=Data;
end

end