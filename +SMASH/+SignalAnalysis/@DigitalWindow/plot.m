% plot Plot window function
%
% This method plots the window function on the current time base in a new
% figure window.
%    plot(object);
%    h=plot(object); % returns graphic handle for plotted line
%
% See also DigitalWindow, evaluate
%
function varargout=plot(object)

figure();
h=plot(object.Time,object.Data);
xlabel('Normalized time');
ylabel('Window value');
label=sprintf('%s window',object.Name);
title(label,'FontWeight','normal');

ylim([0 1]);

% manage output
if nargout > 0
    varargout{1}=h;
end

end