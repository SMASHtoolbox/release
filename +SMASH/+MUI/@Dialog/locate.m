% LOCATE Adjust Dialog location
%
% This method adjusts the location of a custom dialog box.  The position of
% the dialog box can be specified with respect to the entire screen:
%    >> locate(object,location);
% or a reference figure.
%    >> locate(object,location,reference); % reference is a figure handle
% Valid locations are 'center' [default], 'North', 'South', 'East',
% 'West','NorthEast', 'NorthWest', 'SouthEast', and 'SoutWest'.  Outside
% versions of the cardinal directions, such as 'WestOutside', are also
% supported.
%
% See also Dialog
%

% created August 2, 2013 by Daniel Dolan (Sandia National Laboratories)
% modifyed May 12, 2014 by Daniel Dolan
%    -added outside locations
function locate(object,location,reference)

% manage input
verify(object);
if (nargin<2) || isempty(location)
    location='center';
end
assert(ischar(location),'ERROR: invalid location');
location=lower(location);

if (nargin<3) || isempty(reference)
    reference=0;
end

if ~ishandle(reference)
    error('ERROR: invalid reference figure handle');
elseif reference==0 % root object    
    movegui(object.Handle,location);
else % another figure
    units=get(reference,'Units');
    set(reference,'Units','pixels');
    ref=get(reference,'Position');
    pos=get(object.Handle,'Position');
    switch lower(location)
        case 'center'
            pos(1)=ref(1)+ref(3)/2-pos(3)/2;
            pos(2)=ref(2)+ref(4)/2-pos(4)/2;
        case 'north'
            pos(1)=ref(1)+ref(3)/2-pos(3)/2;
            pos(2)=ref(2)+ref(4)-pos(4);
        case 'northoutside'
            pos(1)=ref(1)+ref(3)/2-pos(3)/2;
            pos(2)=ref(2)+ref(4);
        case 'northeast'
            pos(1)=ref(1)+ref(3)-pos(3);
            pos(2)=ref(2)+ref(4)-pos(4);
        case 'northeastoutside'
            pos(1)=ref(1)+ref(3);
            pos(2)=ref(2)+ref(4)-pos(4);
        case 'east'
            pos(1)=ref(1)+ref(3)-pos(3);
            pos(2)=ref(2)+ref(4)/2-pos(4)/2;
        case 'eastoutside'
            pos(1)=ref(1)+ref(3);
            pos(2)=ref(2)+ref(4)/2-pos(4)/2;
        case 'southeast'
            pos(1)=ref(1)+ref(3)-pos(3);
            pos(2)=ref(2);
        case 'southeastoutside'
            pos(1)=ref(1)+ref(3);
            pos(2)=ref(2);
        case 'south'
            pos(1)=ref(1)+ref(3)/2-pos(3)/2;
            pos(2)=ref(2);
        case 'southoutside'
            pos(1)=ref(1)+ref(3)/2-pos(3)/2;
            pos(2)=ref(2)-pos(4);
        case 'southwest'
            pos(1)=ref(1);
            pos(2)=ref(2);        
        case 'southwestoutside'
            pos(1)=ref(1)-pos(3);
            pos(2)=ref(2);  
        case 'west'
            pos(1)=ref(1);
            pos(2)=ref(2)+ref(4)/2-pos(4)/2;
        case 'westoutside'
            pos(1)=ref(1)-pos(3);
            pos(2)=ref(2)+ref(4)/2-pos(4)/2;
        case 'northwest'
            pos(1)=ref(1);
            pos(2)=ref(2)+ref(4)-pos(4);
        case 'northwestoutside'
            pos(1)=ref(1)-pos(3);
            pos(2)=ref(2)+ref(4)-pos(4);
        otherwise
            fprintf('''%s'' is not a valid location--using ''center'' instead\n',...
                options.Location);
            pos(1)=ref(1)+ref(3)/2-pos(3)/2;
            pos(2)=ref(2)+ref(4)/2-pos(4)/2;
    end
    set(object.Handle,'Position',pos);
    movegui(object.Handle,'onscreen'); % make sure dialog appears on the screen
    set(reference,'Units',units);
end

end