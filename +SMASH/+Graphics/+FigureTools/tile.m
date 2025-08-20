% tile Tile figures
%
% This methods tiles MATLAB figures across a monitor.  By default,
% all existing files are horizontally tiled.
%    tile();
% The first input indicates the tiling mode, which can be 'horizontal',
% 'vertical', or row/column specification.
%    tile([3 2]); % three rows, two columns
% Passing an infinite row *or* column specification calculates the smallest
% possible value based on the other (finite) value.
%    tile([inf 2]); % two columns with as many rows as needed
% 
% Tiling is performed over the entire monitor by default.  A normalized
% tile domain can also be defined.
%    tile(mode,[x0 y0 Lx Ly]);
% For example, [0.50 0 0.50 1] places tiled figures on the right half of
% the monitor.
%
% Tiling automatically uses all accessable figures.  Specific figures and
% tiling order can also be specifed manually.
%    tile(mode,domain,fig)
% The input "fig" can be a Figure array or a set of integer figure numbers.
% For example, [1 3 2] indicates tiling with figure 1, then figure 3, and
% finally figure 2.  An error is generated if any of the requested figures
% do not exist.
%
% <a href="matlab:SMASH.System.showExample('Tile','+SMASH/+Graphics/+FigureTools')">Examples</a> 
%
% See also SMASH.Graphics.FigureTools, stack
%

%
% created December 8, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function tile(mode,domain,fig)

% manage input
errmsg='ERROR: invalid tile mode';
if (nargin < 1) || isempty(mode) || strcmpi(mode,'horizontal')
    mode=[1 nan];
elseif strcmpi(mode,'vertical')
    mode=[nan 1];
elseif isnumeric(mode) && (numel(mode) == 2)
    mode(isnan(mode))=inf;
    assert(any(isfinite(mode)),errmsg);   
    assert(all(mode > 0) && all(mode == round(mode)),errmsg);
else
    error(errmsg);
end

if (nargin < 2) || isempty(domain)
    domain=[0 0 1 1];
elseif isnumeric(domain) && (numel(domain) == 4)
    errmsg='ERROR: domain must have finite size and reside inside one display';
    assert((domain(1) >= 0) && (domain(1) <= 1),errmsg);
    assert((domain(2) >= 0) && (domain(2) <= 1),errmsg);
    assert((domain(3) > 0) && (domain(1) + domain(3) <= 1),errmsg);
    assert((domain(4) > 0) && (domain(2) + domain(4) <= 1),errmsg);
else
    error('ERROR: invalid domain');
end

if (nargin < 3) || isempty(fig)  
    fig=findobj(groot,'Type','figure','Visible','on');
    fig=sort(fig);
    if isempty(fig)
        warning('No visible figures available');
        return
    end
else
    assert(all(isgraphics(fig)),'ERROR: invalid figure handle(s)');   
    for m=1:numel(fig)        
        fig(m)=ancestor(fig(m),'figure');
        for n=1:(m-1)
            assert(fig(m) ~= fig(n),'ERROR: repeated figure handle');
        end
        if m == 1
            new=repmat(figure(fig(m)),size(fig));
        else
            new(m)=figure(fig(m));
        end
    end    
    fig=new;
end

if any(~isfinite(mode))
    value=numel(fig)/mode(isfinite(mode));
    mode(~isfinite(mode))=ceil(value);
end
assert(prod(mode) >= numel(fig),'ERROR: there are more figures than tile positions');
for n=1:numel(fig)
    fig(n).WindowStyle='normal';
end

% figure out reference location
fig(1).Units='pixels';
temp=figure('Visible','off','NumberTitle','off',...
    'Menubar','none','Toolbar','none',...
    'Units','pixels','OuterPosition',fig(1).OuterPosition);
CU=onCleanup(@() delete(temp));
temp.Units='normalized';
temp.OuterPosition=domain;
temp.Units='pixels';
figure(temp);
drawnow;
left=temp.OuterPosition(1);
right=temp.OuterPosition(1)+temp.OuterPosition(3);
bottom=temp.OuterPosition(2);
top=temp.OuterPosition(2)+temp.OuterPosition(4);

% tile figures
width=(right-left)/mode(2);
height=(top-bottom)/mode(1);
y0=top;
index=1;
for row=1:mode(1)
    x0=left;
    y0=y0-height;
    for column=1:mode(2)
        if index > numel(fig)
            break
        end
        fig(index).Units='pixels';
        fig(index).OuterPosition=[x0 y0 width height];
        x0=x0+width;       
        index=index+1;
    end
end

for n=numel(fig):-1:1
    figure(fig(n));
end

end