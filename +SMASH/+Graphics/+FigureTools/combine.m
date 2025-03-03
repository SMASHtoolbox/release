% combine Combine figure plots
%
% This method combines plots from one or more figures into a new figure.
%    combine(src1,src2,...);
% Each source input can be a graphic handle or the integer number for an
% existing figure; arrays of either are also supported.  Content from each
% figure is copied into a sub-domain of the new figure, leaving the
% original figures unaltered.  Omitting specific figures:
%    combine();
% merges all standard figures.
% 
% Plots are sequentially rastered across the new figure using a maximum
% number of columns.  By default, the maximum number of columns matches the
% number of source figures, so plots are merged horizontally (1xN for N
% figures).  A smaller number of maximum columns can be specified as the
% first input argument.
%    combine('maxcol=1',...); % vertical merge (Nx1)
%    combine('maxcol=2',...); % two-column merge (ceil(N/2) rows)
% Any number of maximum columns exceeding the number of merged figures
% yields horizontal merging.  The default case is equivalent to:
%    combine('maxcol=inf',...);
%
% Requesting an output:
%    new=combine(...);
% returns the combined figure's graphic handle.
%
% See also SMASH.Graphics.FigureTools, getHandle
%
function varargout=combine(varargin)

% manage input
columns=inf;
if nargin > 0
    entry=varargin{1};
    if ischar(entry) || isStringScalar(entry)
        entry=lower(entry);
        entry=sscanf(entry,'%s'); % remove white space
        [columns,count,~,next]=sscanf(entry,'maxcol=%g',1);
        assert((count == 1) && (columns == ceil(columns))...
            && isempty(entry(next:end)),'ERROR: invalid column request');
    end
    varargin=varargin(2:end);
end

if isempty(varargin)
    src=SMASH.Graphics.FigureTools.getHandle();
    varargin={src};
end

src={};
for m=1:numel(varargin)
    for n=1:numel(varargin{m})
        temp=varargin{m}(n);
        assert(ishandle(temp) && strcmp(get(temp,'Type'),'figure'),...
            'ERROR: invalid figure requested');
        src{end+1}=temp; %#ok<AGROW>
    end

end
count=numel(src);
assert(count > 0,'ERROR: no figures to merge');

% generate combined figure
if columns >= count
    rows=1;
    columns=count;
else
    rows=ceil(count/columns);
end

fig=figure('Units','normalized','OuterPosition',[0 0 1 1]);
box=zeros(1,4);
box(2)=1-1/rows;
box(3)=1/columns;
box(4)=1/rows;

for k=1:count      
    child=findobj(src{k},'Type','axes');
    for m=1:numel(child)
        pos=getpixelposition(child(m));
        ref=getpixelposition(ancestor(child(m),'figure'));
        pos([1 3])=pos([1 3])/ref(3);
        pos([2 4])=pos([2 4])/ref(4);
        % look for legend
        group=child(m);
        hl=findobj(src{k},'Type','legend','Axes',child(m)); % Axes property is hidden in legend objects!
        if ~isempty(hl)
            group(end+1)=hl; %#ok<AGROW>
        end
        % look for colorbar
        hc=findobj(src{k},'Type','colorbar','Axes',child(m)); % Axes property is hidden in colorbar objects!
        if ~isempty(hc)
            group(end+1)=hc; %#ok<AGROW>
        end
        new=copyobj(group,fig);
        new=new(1);
        pos([1 3])=pos([1 3])*box(3);
        pos([2 4])=pos([2 4])*box(4);
        pos(1)=box(1)+pos(1);
        pos(2)=box(2)+pos(2);
        set(new,'OuterPosition',pos);
    end
    if rem(k,columns) == 0
        box(1)=0;
        box(2)=box(2)-1/rows;
    else
        box(1)=box(1)+1/columns;
    end
end

% manage output
if nargout > 0
    varargout{1}=fig;
end

end