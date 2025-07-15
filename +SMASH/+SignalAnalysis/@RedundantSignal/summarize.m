% summarize Summarize correction parameters
%
% This methods summarizes the redundant signal correction parameters.  When
% called with no output:
%    summarize(object);
% these parameters are printed in the command window.  Requesting an
% output:
%    report=summarize(object);
% returns correction parameters as a structure.
%
% See also RedundantSignal, weld
%

%
% created March 25, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=summarize(object)

if nargout == 0
    fprintf('%10s%20s%20s%20s\n',...
        'Signal','Grid shift','Data scale','Data shift');
    for k=1:object.NumberSignals
        fprintf('%10d%+#20g%+#20g%+#20g\n',k,object.Parameter(k,:));
    end
else
    report.GridShift=object.Parameter(:,1);
    report.DataScale=object.Parameter(:,2);
    report.DataShift=object.Parameter(:,3);
    varargout{1}=report;
end

end