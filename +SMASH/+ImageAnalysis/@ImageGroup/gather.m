% GATHER Combine objects into a ImageGroup
% 
% This method combines ImageGroup (and Image) objects into a new ImageGroup
% object with a common Grid.
%    >> new=gather(object1,object2,...)
%
% See also ImageGroup, split
%

%
% created January 7, 2015 by Sean Grant (Sandia National Laboratories/UT)
%
function object=gather(varargin)

temp={};
label={};
grid1Max=-inf;
grid2Max=-inf;
grid1Min=inf;
grid2Min=inf;
dt1=inf;
dt2=inf;
for n=1:nargin
    assert(isa(varargin{n},'SMASH.ImageAnalysis.Image'),...
        'ERROR: non-gatherable object detected')
    source=varargin{n};
    for m=1:size(source.Data,3)
        temp{end+1}=SMASH.ImageAnalysis.Image(...
            source.Grid1,source.Grid2,source.Data(:,:,m)); %#ok<AGROW>                
        grid1Max=max(grid1Max,max(source.Grid1));
        grid2Max=max(grid2Max,max(source.Grid2));
        grid1Min=min(grid1Min,min(source.Grid1));
        grid2Min=min(grid2Min,min(source.Grid2));
        dt1=min(dt1,min(diff(source.Grid1)));
        dt2=min(dt2,min(diff(source.Grid2)));
        switch class(source)
            case 'SMASH.ImageAnalysis.Image'
                label{end+1}=source.Name; %#ok<AGROW>
            case 'SMASH.ImageAnalysis.ImageGroup'
                label{end+1}=source.Legend{m}; %#ok<AGROW>
        end
    end
end

N=numel(temp);
% [temp{:}]=register(temp{:});
% dataSize = size(temp{1}.Data);

% Data=nan(dataSize(1),dataSize(2),N);
% N1=round((grid1Max-grid1Min)/dt1);
% N2=round((grid2Max-grid2Min)/dt2);
% newGrid1=linspace(grid1Min,grid1Min+N1*dt1,N1+1);
% newGrid2=linspace(grid2Min,grid2Min+N2*dt2,N2+1);
x1=grid1Min:dt1:grid1Max;
x2=grid2Min:dt2:grid2Max;

Data=nan(numel(x2),numel(x1),N);
for n=1:N
    temp{n}=regrid(temp{n},x1,x2); %#ok<AGROW>
    Data(:,:,n)=temp{n}.Data;
end
object=SMASH.ImageAnalysis.ImageGroup(x1,x2,Data);
object.Source='Image merge';
object.Grid1Label=varargin{1}.Grid1Label;
object.Grid2Label=varargin{1}.Grid2Label;
object.DataLabel=varargin{1}.DataLabel;
object.NumberImages=size(object.Data,3);
object.Legend=label;

end