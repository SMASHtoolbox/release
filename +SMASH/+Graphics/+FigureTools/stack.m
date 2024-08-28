% stack Stack figures
%
% This method stacks figures into a pile, matching the size of the top
% figure.  
%    stack(); % stack all accessible figures
%    stack(fig); % stack particular figures
% Stacking order is defined by the input "fig": the first figure is on top,
% followed by the second, and so forth.
%
% See also SMASH.Graphics.FigureTools, tile
%

%
% created December 8, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function stack(fig)

% manage input
if (nargin < 1) || isempty(fig)
    %fig=get(groot,'Children');
    fig=findobj(groot,'Type','figure','Visible','on');
    fig=sort(fig);
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

% stack figures behind the first one
pos=getpixelposition(fig(1));
for n=numel(fig):-1:1
    setpixelposition(fig(n),pos);
    figure(fig(n));
end

end