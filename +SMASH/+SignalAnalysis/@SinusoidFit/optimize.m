% UNDER CONSTRUCTION
%


function optimize(object,index)

assert(object.NumberSinusoids > 0,'ERROR: no sinusoids defined');

% manage input
valid=1:object.NumberSinusoids;
if (nargin < 2) || isempty(index)
    index=valid;
elseif isnumeric(index)
    for k=1:numel(index)
        assert(any(index(k) == valid),'ERROR: invalid sinusoid index');
    end
elseif strcmpi(index,'first')
    index=1;
elseif strcmpi(index,'last')
    index=object.NumberSinusoids;
else
    assert(isnumeric(bound),'ERROR: invalid sinusoid index');
end

% manage bounds
center=object.Parameter(index,1);
guess=zeros(size(center));
width=1/object.Duration;

% perform optimization
fminsearch(@residual,guess,object.Optimization);
    function chi2=residual(param)
        for kk=1:numel(index)
            slack=param(kk);
            value=center(kk)+width*sin(slack);
            move(object,value,index(kk));
        end
        temp=split(object.Spectrum,2);
        chi2=mean(abs(temp.Data).^2);
    end

end