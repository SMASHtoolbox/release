% clean Remove preview/reduction backups
%
% This method removes all preview and reduction backups, leaving only the
% most recent results.
%    clean(object);
%
% See also SFR, reduce, preview
%
function clean(object)

for n=1:numel(object)    
    data=object(n).Preview;
    if numel(data) > 1
        object(n).Preview=data(end);
    end
    
    data=object(n).Reduction;
    if numel(data) > 1
        object(n).Reduction=data(end);
    end
end

end