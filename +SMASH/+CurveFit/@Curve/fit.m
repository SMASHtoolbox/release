% fit Optimize parameters to match data
%
% This method optimizes the parameters and non-fixed scaling factors of a
% Curve object to best fit a data set.
%     object=fit(object);
% Optimization options can be passed as a second input.
%     >> object=fit(object,options);
% The MATLAB function "optimset" should be used to generate the options
% structure.
%
% See also Curve, evaluate, optimset, summarize
%

%
% created December 1, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function object=fit(object,options)

assert(~isempty(object.DataTable),'ERROR: data table not defined');

% manage input
if (nargin < 2) || isempty(options)
    options=optimset();
end

% prepare parameter arrays
Nbasis=numel(object.Basis);
start=nan(1,Nbasis);
stop=nan(1,Nbasis);
guess=[];
lower=[];
upper=[];

for m=1:Nbasis
    if m==1
        start(m)=1;
    else
        start(m)=stop(m-1)+1;
    end
    param=object.Parameter{m};
    assert(~any(isinf(param)),'ERROR: infinite parameter detected');
    assert(~any(isnan(param)),'ERROR: nan parameter detected');
    Nparam=numel(param);
    stop(m)=start(m)+Nparam-1;
    for n=1:Nparam
        lower(end+1)=object.Bound{m}(1,n); %#ok<AGROW>
        upper(end+1)=object.Bound{m}(2,n); %#ok<AGROW>
        if param(n)<lower(end)
            param(n)=lower(end);
            warning('SMASH:CurveFit',...
                'Invalid parameter detected, using lower bound instead');
        elseif param(n)>upper(end)
            param(n)=upper(end);
            warning('SMASH:CurveFit',...
                'Invalid parameter detected, using upper bound instead');
        end
        guess(end+1)=bound2free(param(n),lower(end),upper(end)); %#ok<AGROW>
    end
end
Ntotal=numel(guess);

% perform optimization
data=object.DataTable;
x=data(:,1);
y=data(:,2);
weight=object.Weight;

fixed=false(1,Nbasis);
for m=1:Nbasis
    if object.FixScale{m}
        fixed(m)=true;
    end
end

%object.FitTable=[];
if numel(guess) > 0
    slack=fminsearch(@residual,guess,options);
else
    slack=[];
end
[~,scale,param]=residual(slack);
    function [chi2,scale,param]=residual(slack)
        % parameter conversion
        param=slack;
        for j=1:Ntotal
            param(j)=free2bound(slack(j),lower(j),upper(j));
        end
        scale=nan(Nbasis,1);
        for j=1:Nbasis
            object.Parameter{j}=param(start(j):stop(j));
            scale(j)=object.Scale{j};
        end
        [~,basis]=evaluate(object,x);
        % reduced basis
        if sum(fixed) == 0
            y_fixed=0;
        else                        
            %y_fixed=bsxfun(@mtimes,basis(:,fixed),scale(fixed)');
            y_fixed=basis(:,fixed)*scale(fixed);
        end       
        y_reduced=y-y_fixed;
        basis_reduced=basis(:,~fixed);
        scale_reduced=distinctLLS(basis_reduced,y_reduced);
        fit_reduced=basis_reduced*scale_reduced;
        fit=fit_reduced+y_fixed;
        scale(~fixed)=scale_reduced;
        % residual calculation with complex values and weight support
        chi2=y-fit;
        if isempty(weight)
            chi2=real(chi2.*conj(chi2));
        else
            chi2=weight.*real(chi2.*conj(chi2));
        end
        chi2=sum(chi2);
        %temp=[param(:); scale(:)];
        %object.FitTable(:,end+1)=temp(:);
    end

for m=1:Nbasis
    object.Parameter{m}=param(start(m):stop(m));
    object.Scale{m}=scale(m);   
end

object.FitComplete=true;

end