% isfigure : true for existing figure handles
%
% Created 9/22/2004 by Daniel Dolan
function func=isfigure(handle)

if nargin<1
    error('Not enough input arguments.');
end

if isempty(handle) % empty handle cannot be valid
    func=logical(0);
    return
else % default assumption is that everthing is invalid
    func=logical(zeros(size(handle)));
end

for ii=1:numel(handle)
    if ishandle(handle(ii))
        type=lower(get(handle(ii),'Type'));
        if strcmp(type,'figure') % valid figure handle
            func(ii)=logical(1);
        end
    end
end