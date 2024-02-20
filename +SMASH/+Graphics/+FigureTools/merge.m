% UNDER CONSTRUCTION
%
%
%  merge(dimensions);
%  merge(dimensions,source1,source2,...)


function varargout=merge(varargin)

if nargin == 0
    fig=findobj(groot,'Type','figure');
    assert(~isempty(fig),'ERROR: no figures found');
    N=numel(fig);
    for n=1:N
        varargin{n}=fig(n);
    end    
end

first=varargin{1};
if isnumeric(first) && (numel(first) == 2)
    first=round(first);
    assert(all(first >= 1),'ERROR: invalid dimensions');
    dimensions=first;
    varargin=varargin{}
else

end

%
if nargout > 0
    varargout{1}=new;
end

end