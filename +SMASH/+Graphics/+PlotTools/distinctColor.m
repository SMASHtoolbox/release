% distinctColor Generate maximally distinct color
% 
% This function generates maximally distinct colors relative to a
% three-column map.  The minimum distance of these values (in RGB
% space) is maximized for greatest visual clarity.
%    color=distinctColor(map);
% The ouput "color" is a three-column matrix.  Each matrix row defines one
% maximally distinct color value.
%
% The demonstration mode of this function:
%    distinctColor('demo');
% compares distinctly colored lines with MATLAB's standard color maps.
%
% See also SMASH.Graphics.PlotTools
%

%
% created February 17, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function color=distinctColor(map,refine)

% manage input
if (nargin == 1) && strcmpi(map,'demo')
    runDemo()
    return
end

errmsg='ERROR: invalid color map';
if (nargin < 1) || isempty(map)
    map=colormap(gca);
elseif ishandle(map)
    fig=ancestor(map,'figure');   
    map=colormap(fig.CurrentAxes);
elseif isnumeric(map) && ismatrix(map) && (size(map,2) == 3)
    assert(all(map(:) >= 0) && all(map(:) <= 1),errmsg);
else
    error(errmsg);
end

if (nargin < 2) || isempty(refine) || strcmpi(refine,'refine')
    refine=true;
else
    refine=false;
end

% generate score on coarse grid
spacing=0.1;
[red,green,blue]=ndgrid(0:spacing:1);
color=[red(:) green(:) blue(:)];
N=size(color,1);

score=nan(N,2);
for n=1:N
    distance=bsxfun(@minus,map,color(n,:));
    distance=sqrt(sum(distance.^2,2));
    score(n,1)=min(distance);
    score(n,2)=median(distance);
end
keep=abs(score(:,1)-max(score(:,1))) <= (spacing/2);
color=color(keep,:);

score=score(keep,2);
value=max(score);
keep=(score >= value);
color=color(keep,:);

% refine color(s)
if refine
    for k=1:size(color,1)
        guess=asin((color(k,:)-0.5)/0.5);
        result=fminsearch(@residual,guess);
        [~,color(k,:)]=residual(result);
    end
end
    function [L2,RGB]=residual(slack)
        RGB=0.5+0.5*sin(slack);
        L2=bsxfun(@minus,map,RGB).^2;
        L2=-min(sum(L2,2));
    end

%if size(color,1) > 1
%    warning('This map has %d maximally distinct colors',size(color,1));
%end

end

function runDemo()

figure;
list={'parula' 'jet' 'hsv' 'hot' 'cool' ...
    'spring' 'summer' 'autumn' 'winter' ...
    'gray' 'bone' 'copper' 'pink' ...
    'lines' 'colorcube' 'prism'}; %'flag'};

N=numel(list);
columns=ceil(sqrt(N));
rows=floor(sqrt(N));
for n=1:N
    subplot(rows,columns,n);
    map=feval(list{n},64);
    if n == 1
        [x,~]=meshgrid(1:256);        
    end
    imagesc(x);
    colormap(gca,map);
    axis tight;
    axis off;
    new=packtools.call('distinctColor',map);
    line(xlim,ylim,'LineWidth',2,'Color',new(1,:));
    title(list{n});
end

end