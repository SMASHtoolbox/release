% analyze Analyze parameter uncertainty
%
% This method analyzes parameter uncertainty for a Curve object.
%    report=analyze(object,iterations);
% The input "interations" is optional (default value is 1000) and can be
% any positive integer.  Larger iteration numbers take more time but
% produce more reliable results.
%
% The output "report" is a Cloud object describing the variation in all
% basis parameters and scale factors.  NOTE: this method cannot be used
% until the fit method has been called.  Adding, removing, and editing the
% basis functions in a Curve object require the fit method to be called
% before uncertainty analysis.
%
% See also CurveFit, fit, SMASH.MonteCarlo.Cloud
%

%
% created January 17, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function [report,reject]=analyze(object,iterations)

assert(object.FitComplete,...
    'ERROR: fit must be performed before uncertainty analysis');

% manage input
if (nargin < 2) || isempty(iterations)
    iterations=1000;
end 
assert(...
    SMASH.General.testNumber(iterations,'positive','integer','notzero'),...
    'ERROR: invalid interations value');


% extract data
data=object.DataTable;
x=data(:,1);
y=data(:,2);
weight=object.Weight;
if isempty(weight)
    weight=mean((y-evaluate(object,x)).^2);
    weight=repmat(1/weight,size(x));
end

state0=[];
state_min=[];
state_max=[];
Nbasis=numel(object.Basis);
Nadjustable=zeros(1,Nbasis);
for k=1:Nbasis
    Nadjustable(k)=numel(object.Parameter{k});
    state0=[state0 object.Parameter{k}]; %#ok<AGROW>
    state_min=[state_min object.Bound{k}(1,:)]; %#ok<AGROW>
    state_max=[state_max object.Bound{k}(2,:)]; %#ok<AGROW>
    if ~object.FixScale{k}
        Nadjustable(k)=Nadjustable(k)+1;
        state0(end+1)=object.Scale{k}; %#ok<AGROW>
        state_min(end+1)=-inf; %#ok<AGROW>
        state_max(end+1)=+inf; %#ok<AGROW>
    end
end

    function L=likelihood(state)
        % update *adjustable* parameters
        new=object;
        for kk=1:Nbasis
            temp=state(1:Nadjustable(kk));
            if ~object.FixScale{kk}
                new=edit(new,kk,'Scale',temp(end));
                temp=temp(1:end-1);
            end
            new=edit(new,kk,'Parameter',temp);
            state=state(Nadjustable(kk)+1:end);
        end
        fit=evaluate(new,x);
        L=weight/2.*(fit-y).^2;
        L=exp(-sum(L));
    end

%%
MC=SMASH.MonteCarlo.MetropolisHastings(state0);
MC=define(MC,'ProbabilityFunction',@likelihood);
[~,MC]=survey(MC);
[report,reject]=analyze(MC);

% manage output
label=report.VariableName;
k=0;
for m=1:Nbasis
    for n=1:numel(object.Parameter{m})
        k=k+1;
        label{k}=sprintf('Basis %d Parameter %d',m,n);
    end
    if ~object.FixScale{m}
        label{end-Nbasis+m}=sprintf('Basis %d Scale factor',m);
    end
end
report=configure(report,'VariableName',label);

end