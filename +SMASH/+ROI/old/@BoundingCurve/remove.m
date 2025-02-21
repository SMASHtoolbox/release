% remove Manually remove points from a BoundingCurve
%
% This method removes points from a BoudingCurve object
%    >> object=remove(object,index);
%    >> object=remove(object,'all');
%
% See also BoundingCurve, define, insert, select
%

%
% created November 18, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function remove(object,varargin)

Narg=numel(varargin);
% index modes
if Narg==1
    if isnumeric(varargin{1})
        index=varargin{1};
        assert(all(index==round(index)),'ERROR: invalid index');
        M=size(object.Data,1);
        assert(all(M>=1) & all(M<=M),'ERROR: invalid index');
        keep=true(M,1);
        keep(index)=false;
        object.Data=object.Data(keep,:);       
    elseif strcmpi(varargin{1},'all')
        object.Data=[];
    end    
end

% nearest mode
if Narg==2
    x=varargin{1};
    y=varargin{2};
    assert(isnumeric(x) & isnumeric(y),'ERROR: invalid input');
    assert(numel(x)==numel(y),'ERROR: invalid input');
    for k=1:numel(x)
        L2=(x(k)-object.Data(:,1)).^2+(y(k)-object.Data(:,2)).^2;
        [~,index]=min(L2);
        object=remove(object,index);
    end
end

end