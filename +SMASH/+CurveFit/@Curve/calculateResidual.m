%%
function varargout=calculateResidual(object)

x=object.DataTable(:,1);
y=object.DataTable(:,2);

ye=evaluate(object,x);
Delta=ye-y;
raw=Delta.^2.*object.Weight;
raw=sum(raw);
N=numel(object.Parameter);

Nparam=0;
for n=1:N
    Nparam=Nparam+numel(object.Parameter{n}); % basis function parameters
end
Nparam=Nparam+N; % one scale factor per basis function
dof=numel(x)-Nparam;
reduced=raw/dof;

% manage output
if nargout() > 0
    varargout{1}=reduced;   
    varargout{2}=raw;
    varargout{2}=dof;
    return
end
fprintf('Reduced chi2 = %g\n',reduced);
fprintf('based on residual = %g and DOF = %g\n',raw,dof);
figure();
plot(x,Delta,'o');
yline(0,'Color','k');

end