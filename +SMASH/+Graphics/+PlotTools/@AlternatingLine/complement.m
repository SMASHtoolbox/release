% complement Assign complment color
%
% This function assigns the background line color to be the complement of
% the foreground line color.
%     >> complement(object);
%
% See also AlternatingLines
%

%
% created December 10, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function complement(object)

color=object.ForegroundColor;
if isnumeric(color)
    new=1-color;
    change=abs(new-color);
    assert(any(change>0.05),...
        'ERROR: requested color is too close to its complement to be distinct');
    object.BackgroundColor=new;
elseif strcmp(color,'black') || strcmp(color,'k')
    object.BackgroundColor='white';
elseif strcmp(color,'white') || strcmp(color,'w')
    object.BackgroundColor='black';
elseif strcmp(color,'red') || strcmp(color,'r')
    object.BackgroundColor='cyan';
elseif strcmp(color,'cyan') || strcmp(color,'c')
    object.BackgroundColor='red';
elseif strcmp(color,'green') || strcmp(color,'g')
    object.BackgroundColor='magenta';
elseif strcmp(color,'magenta') || strcmp(color,'m')
    object.BackgroundColor='green';
elseif strcmp(color,'blue') || strcmp(color,'b')
    object.BackgroundColor='yellow';
elseif strcmp(color,'yellow') || strcmp(color,'y')
    object.BackgroundColor='blue';
else
    error('ERROR: complement cannot be generated');
end

end