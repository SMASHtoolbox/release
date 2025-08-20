% This method sets custom line properties.
%
%    >> set(object,name,value,...)
%

%
function set(object,varargin)

Narg=numel(varargin);
if rem(Narg,2)==1
    error('ERROR: unmatched name/value pair');
end

for n=1:2:Narg
    name=varargin{n};
    value=varargin{n+1};
    switch lower(name)
        otherwise
            set(object.Handle,name,value);
    end
end

end