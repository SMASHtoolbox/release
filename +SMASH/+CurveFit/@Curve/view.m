% view View curve with data
%
% This method displays a plot of the current curve with the fit data.
%    view(object);
% Requesting an ouput:
%    hl=view(object);
% returns graphic handles for the line objects in the plot.
%
% See also Curve, evaluate
%

%
% created April 16, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object)

% primary plot
x=object.EvaluationGrid;
y=evaluate(object,x);
figure;
hl=plot(object.DataTable(:,1),object.DataTable(:,2),'ro',...
    x,y,'k');
hl(2).LineWidth=2;
xlabel(object.GridLabel);
ylabel(object.DataLabel);

% error bars (where applicable)
if ~isempty(object.Weight)
    hold on
    errorbar(object.DataTable(:,1),object.DataTable(:,2),...
        object.DataTable(:,3));
    hold off
end

% manage output
if nargout > 0
    varargout{1}=hl;
end

end