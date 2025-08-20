% copy Copy records between archives
%
% This method copies records from the current archive to another archive.
%    copy(object,destination,label);
% The input "destination" must be a valid SDA file; that file will be
% created if it does not already exist.
%
% See also SDAfile
%

%
% created May 6, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function copy(object,destination,label)

% manage input
assert(nargin > 1,'ERROR: no destination specified');

try
    new=SMASH.FileAccess.SDAfile(destination);
catch ME
    throwAsCaller(ME);    
end

if (nargin < 3) || isempty(label)
    label=probe(new);
elseif ischar(label)
    label={label};    
else
    if isstring(label)
        label=cellstr(label);    
    end
    assert(iscellstr(label),'ERROR: invalid label request'); %#ok<ISCLSTR>
end

% copy records
for m=1:numel(label)
    list=probe(object,label{m});
    for n=1:numel(list)
        % verify source
        [~,type]=probe(object,list{n});
        if any(regexp(type{1},'file'))
            warning('Cannot copy file records');
            continue
        end
        [previous,metadata]=extract(object,list{n});
        % store record with unique label
        current=probe(new);
        current{end+1}=list{n}; %#ok<AGROW>
        current=matlab.lang.makeUniqueStrings(current);
        insert(new,current{end},previous,...
            metadata.Description,metadata.Deflate);        
    end
end

end