function showExample(name)

% manage input
assert(nargin > 0,'ERROR: no example name');
try
    name=packtools.call('Script.extractExample',name);    
catch
    error('ERROR: invalid example name');
end

errmsg='ERROR: examples must be opened one at a time';
assert(numel(name) == 1,errmsg);
name=name{1};
[~,~,ext]=fileparts(name);
assert(strcmpi(ext,'.m') || strcmpi(ext,'.mlx'),errmsg)

[location,name,~]=fileparts(name);
temp=dir(fullfile(location,[name '.*']));
name=fullfile(location,temp.name);

edit(name);


end