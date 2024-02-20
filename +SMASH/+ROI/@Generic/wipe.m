% wipe Delete ROI displays
%
% This method wipes displayed regions of interest from an axes.
%    wipe(object); % wipe current axes
%    wipe(object,target); % wipe target axes
% By default, only regions of interest of the same type are wiped.  All
% regions of interest can be wiped by adding a third input.
%    wipe(object,target,'all'); % remove all ROIs from the target axes
%    wipe(object,target,'same'); % remove only ROIs of the same type
%
%

%
% created October 1, 2017 by Daniel Dolan (Sandia National Laboratory)
%
function wipe(object,target,mode)

% manage input
if (nargin < 2) || isempty(target)
    target=gca;
elseif isscalar(target)
    assert(ishandle(target) && strcmpi(get(target,'Type'),'axes'),...
    'ERROR: invalid target axes');
end

if (nargin < 3) || isempty(mode)
    mode='same';
end
assert(ischar(mode),'ERROR: invalid mode');

% deal with multiple targets
if numel(target) > 1
    for n=1:numel(target)
        wipe(object,target(n),mode);
    end
    return
end


% perform wipe
name=class(object);
switch lower(mode)
    case 'same'
        h=findobj(target,'Tag',name);
    case 'all'
        list=packtools.search('.','*');             
        h=[];
        for n=1:numel(list)
            if exist(list{n},'class')
                temp=findobj(target,'Tag',list{n});
                h=[h; temp(:)]; %#ok<AGROW>
            end
        end
    otherwise
        error('ERROR: invalid mode');
end
delete(h);

end