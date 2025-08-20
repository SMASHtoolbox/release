% listFolders Generate folder list
%
% This function generates a list of folders using one or more input
% arguments.
%    folder=listFolders(source1,source2,...);
% Each input argument can be a character array, cell array of strings,
% string array.  The output "folder" is a cell array of strings of existing
% folder names derived from each input source, allowing for name wildcards.
%
% Calling this function with no output:
%    listFolders(source1,source2,...);
% prints a list of valid folders in the command window.
%
% Note: the list of folders returned by this function is automatically
% sorted and duplicate entries removed.
%
% See also SMASH.System
%
function varargout=listFolders(varargin)

N=nargin();
if N == 0
    varargin{1}=pwd();
    N=1;
end

out={};
for n=1:N
    source=varargin{:};
    if ischar(source)
        source={source};
    elseif isstring(source)
        source=cell(source);
    else
        assert(iscellstr(source),'ERROR: invalid folder source'); %#ok<ISCLSTR> 
    end
    for m=1:numel(source)
        if isfolder(source{m})
            temp=dir(source{m});            
            out{end+1}=temp(1).folder; %#ok<AGROW> 
            continue
        end
        temp=dir(source{m});
        for k=1:numel(temp)
            if ~temp(k).isdir || any(strcmp(temp(k).name,{'.' '..'}))
                continue
            end
            out{end+1}=fullfile(temp(k).folder,temp(k).name); %#ok<AGROW> 
        end
    end
end
out=unique(out);

% manage output
if nargout > 0
    varargout{1}=out;
    return
end
fprintf('Folder list:\n');
fprintf('   %s\n',out{:});

end