% summarize Summarize basis functions
%
% This method summarizes the  basis functions of a Curve object. The basic
% call:
%     >> summarize(object);
% displays all existing basis functions.  To summarize a specific function,
% pass the basis index.
%     >> summarize(object,index);
% When no ouput are specified, the summary is written in the command
% window.  Specific results can be assigned to outputs as shown below.
%     >> [basis,param,bound,scale,fixed]=summarize(...);
%
% See also Curve, add, edit, remove
%

%
% created November 30, 2014 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object,index)

% handle input
N=numel(object.Basis);
if (nargin<2) || isempty(index)
    index=1:N;
end

% verify index values
valid=1:N;
for k=1:numel(index)
    assert(any(index(k)==valid),'ERROR: invalid index');
end

% extract information
basis=object.Basis;
param=object.Parameter;
bound=object.Bound;
scale=object.Scale;
fixed=object.FixScale;

% handle output
if nargout==0    
    fprintf('Object uses %d basis functions\n',N);
    for k=1:N        
        fprintf('\tBasis %d: %s\n',k,func2str(object.Basis{k}));
        fprintf('\tParameter(s): ');fprintf('%+.6g ',object.Parameter{k});fprintf('\n');
        fprintf('\tLower bound(s): ');fprintf('%+.6g ',object.Bound{k}(1,:));fprintf('\n');
        fprintf('\tUpper bound(s): ');fprintf('%+.6g ',object.Bound{k}(2,:));fprintf('\n');
        fprintf('\tScale factor: %+.6g ',object.Scale{k});
        if fixed{k}
            fprintf('(fixed)\n');
        else
            fprintf('(variable)\n');
        end
        fprintf('\n');
    end
else
    report=struct();
    for k=1:N
        report(k).Basis=basis{k};
        report(k).Parameter=param{k};
        report(k).Bound=bound{k};
        report(k).Scale=scale{k};
        report(k).ScaleFixed=fixed{k};
    end
    varargout{1}=report;
end


end