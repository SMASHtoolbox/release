% view View grouped data
%
% This method displays grouped data plots in a new figure.
%    view(object,GridColumn,DataColumn);
% The input "GridColumn" defines the column(s) used for the horizontal
% axes.  The input "Data" indicates the columns(s) used for the vertical
% axes.  Both of these inputs can be arrays, in which case data is
% displayed in series of subplots.
%
% Plot options may be passed as name value pairs after the grid/data column
% definition.
%    view(object,GridColumn,DataColumn,name,value,...);
% Valid options include:
%    -'Marker' defines the marker type(s) (cell array).
%    -'Color' defines the marker color(s) (cell array or three-column color map).
%    -'Size' defines the marker sizes (numeric array).
% Plots cycle through marker type, then marker color, and finally
% marker size to cover all data groups.  For example, specifying {'o' 'sq'}
% markers and {'k' 'r'} colors plots black circles, black squares, red
% circles, and then red squares.  Larger marker sizes are used, as needed,
% to uniquely cover all data groups.
% 
% NOTE: this method *never* uses the group column for grid or data values.
% This means that the number of subplot rows/columns is always smaller than
% the number of table columns.
%
% See also GroupedTable
%

%
% created March 1, 2018 by Daniel Dolan (Sandia National Laboratories)
% 
function varargout=view(object,GridColumn,DataColumn,varargin)

% manage input
errmsg='ERROR: invalid grid column request';
if (nargin < 2) || isempty(GridColumn)
    GridColumn=1;
    if object.GroupColumn == 1
        GridColumn=2;
    end
else
    assert(verifyColumn(object,GridColumn),errmsg);
end
keep=~(GridColumn == object.GroupColumn);
GridColumn=GridColumn(keep);
assert(~isempty(GridColumn),errmsg);

errmsg='ERROR: invalid data column request';
if (nargin < 3) || isempty(DataColumn)
    DataColumn=1:object.Columns;
else
    assert(verifyColumn(object,DataColumn),errmsg);
end
keep=(DataColumn ~= object.GroupColumn);
DataColumn=DataColumn(keep);
assert(~isempty(DataColumn),errmsg);

Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
option.Marker={'o' '+' '*' 'x' 'square' 'diamond' 'v'  '^'  '>' '<' 'pentagram' 'hexagram' };
option.Color={'k' 'r' 'b'};
option.MarkerSize=get(groot,'DefaultLineMarkerSize');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'marker'
            errmsg='ERROR: invalid marker value';
            if ischar(value)
                value={value};
            else
                assert(iscellstr(value),errmsg);
            end            
            option.Marker=value;
        case 'color'
            errmsg='ERROR: invalid color';
            if ischar(value)
                value={value};            
            end
            if iscell(value)
                for k=1:numel(value)
                    assert(SMASH.General.testColor(value{k}),errmsg);
                end
            elseif isnumeric(value)
                new=cell(1,size(value,1));                
                for k=1:size(value,1)
                    assert(SMASH.General.testColor(value(k,:)),errmsg);
                    new{k}=value(k,:);
                end
                value=new;
            else
                error(errmsg);
            end
            option.Color=value;
        case 'markersize'
            errmsg='ERROR: invalid marker size';
            assert(isnumeric(value),errmsg);
            option.MarkerSize=value;
        otherwise
            error('ERROR: %s is not a valid option name');
    end
end
Nmarker=numel(option.Marker);
Ncolor=numel(option.Color);
Nsize=numel(option.MarkerSize);

    
% generate plots
SMASH.MUI.Figure();

M=numel(DataColumn);
N=numel(GridColumn);
data=extract(object);
label=cell(size(data));

if (Nmarker*Ncolor*Nsize) < numel(data)
    new=ceil(numel(data)/(Nmarker*Ncolor));
    for n=Nsize:new
        option.MarkerSize(end+1)=option.MarkerSize(end)*1.5;
    end
end

for k=1:numel(data)
    label{k}=sprintf('%s=%g',object.Label{object.GroupColumn},...
        mean(data(k).GroupList));
    for m=1:M
        y=data(k).Data(:,DataColumn(m));
        for n=1:N
            x=data(k).Data(:,GridColumn(n));
            subplot(M,N,(m-1)*N+n);
            [MarkerIndex,ColorIndex,SizeIndex]=...
                ind2sub([Nmarker Ncolor Nsize],k);
            line(x,y,'LineStyle','none',...
                'Marker',option.Marker{MarkerIndex},...
                'Color',option.Color{ColorIndex},...
                'MarkerSize',option.MarkerSize(SizeIndex),...
                'Tag',sprintf('Data%d_Grid%d_Group%d',DataColumn(m),GridColumn(n),k));
            xlabel(object.Label{GridColumn(n)});
            ylabel(object.Label{DataColumn(m)});                       
        end
    end
end
ha=findobj(gcf,'Type','axes');
set(ha,'Box','on');

for m=1:M
    for n=1:N
        subplot(M,N,(m-1)*N+n);
        legend(label,'Location','best');
    end
end

% manage output
if nargout > 0
    varargout{1}=findobj(gcf,'Type','line');
    varargout{2}=option;   
end

end