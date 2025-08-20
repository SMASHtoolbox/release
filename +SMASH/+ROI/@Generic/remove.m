% remove Remove region(s) of interest
%
% This method removes regions of interest from an array.
%    object=remove(object,index);
% The last element is removed when no index is specified.
%

%
% created September 22, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function object=remove(object,index)

% manage input
if (nargin < 2) || isempty(index)
    index=numel(object);
elseif strcmpi(index,'all')
    index=1:numel(object);
    
end

valid=1:numel(object);
keep=false(size(object));
for n=1:numel(object)
    try
        keep(n)=~any(index == valid(n));
    catch
        error('ERROR: invalid index');
    end
end

object=object(keep);

end