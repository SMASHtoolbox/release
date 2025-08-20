% findTags Find tagged graphics
%
% This function finds tagged graphics within a parent object.
%    h=findTags(parent);
% The output "h" is a structure of object handles named by tag; untagged
% objects are *not* returned.  
%
% The input "parent" indicates the parent object 
%
% See also SMASH.MUI, guihandles
%

%
% created April 14, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function h=findTags(parent)

% manage input
if (nargin < 1) || isempty(parent)
    parent=gcf;
end

% find tagged objects within the specified parent
h=guihandles(parent);

name=fieldnames(h);
for m=1:numel(name)
    data=h.(name{m});
    keep=false(size(data));
    for n=1:numel(data)
        temp=data(n);        
        while true
            if temp == parent
                keep(n)=true;
                break
            elseif strcmpi(temp.Type,'figure')
                break
            else
                temp=temp.Parent;
            end
        end        
    end
    data=data(keep);
    if isempty(data)
        h=rmfield(h,name{m});
    else
        h.(name{m})=data;
    end
end


end