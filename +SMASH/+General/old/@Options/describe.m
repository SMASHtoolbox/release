% describe Show/add option description
%
% This method shows object descriptions.
%     >> describe(object,name); % specific option
%     >> describe(object); % all options
% 
% Option descriptions are also controlled with this method.  To change a
% description:
%     >> object=decribe(object,name,description);
% where the input "description" is a character array or a cell array of
% character arrays (one for each line of text); an empty character array
% ('') indicates that the description should not be changed.
%
% Descriptions can be locked to prevent accidental changes.
%     >> object=decribe(object,name,description0,'locked');
% Once a description has been locked, it must be manually unlocked before
% changes can be made.
%     >> object=decribe(object,name,'','unlocked'); % description0 remains in effect
%     >> object=decribe(object,name,revision,'locked'); % lock revised description
%
% See also Options, add, describe, get
%

%
% created November 17, 2014 by Daniel Dolan (Sandia National Laboratory)
%
function varargout=describe(object,name,description,lock)

% handle input
if (nargin<2) && (nargout==0)
    [~,index]=sort(object.Name);
    for k=index
        fprintf('\n%s:\n',object.Name{k});
        describe(object,object.Name{k});
    end
    return
end
index=findName(object.Name,name);
assert(~isempty(index),'ERROR: option %s not found',name);

if (nargin<4) || isempty(lock)
    lock=object.DescriptionLock{index};
elseif strcmpi(lock,'lock') || strcmpi(lock,'locked')
    lock=true;
else
    lock=false;
end

% access/update requested option
if nargin>=3
    if isempty(description)
        description=object.Description{index};
    end
    assert(ischar(description) | iscell(description),...
        'ERROR: invalid description');
    if object.DescriptionLock{index}
        error('ERROR: description is locked');
    end
    
    info=description;
else
    info=object.Description{index};
end

% handle output
if nargout==0
    if ischar(info)
        info={info};
    end
    fprintf('\t%s\n',info{:});
else
    object.Description{index}=info;
    object.DescriptionLock{index}=lock;
    varargout{1}=object;
end


end