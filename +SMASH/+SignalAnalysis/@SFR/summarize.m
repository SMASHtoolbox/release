% summarize Summarize object status
%
% This method generates a status summary, including noise level and the
% number of previews/reductions.  This information can be printed in the
% command window:
%    summarize(object);
% or returned as a structure.
%    report=summarize(object);
%
% See also SFR, plot
%
function varargout=summarize(object)

report=struct('Noise',[],'Previews',[],'Selections',[],'Reductions',[]);
report=repmat(report,size(object));
for n=1:numel(object)    
    report(n).Noise.RMS=object(n).Noise.RMS;
    report(n).Noise.Source=object(n).Noise.Source;    
    %report(n).Bandwidth.Value=object(n).Bandwidth;
    %report(n).Bandwidth.Source=object(n).BandwidthSource;
    report(n).Previews=numel(object(n).Preview);
    report(n).Selections=numel(object(n).Selection);
    report(n).Reductions=numel(object(n).Reduction);
end

if nargout > 0
    varargout{1}=report;
    return
end

for n=1:numel(report)
    fprintf('%s summary:\n',object(n).Name);
    fprintf('   RMS noise is %g (%s)\n',...
        report(n).Noise.RMS,report(n).Noise.Source);
    %fprintf('   Bandwidth is %g (%s)\n',...
    %    report(n).Bandwidth.Value,report(n).Bandwidth.Source);
    label=SMASH.Text.sprintPlural(report(n).Previews,'preview');
    fprintf('   %s generated\n',label);
    label=SMASH.Text.sprintPlural(report(n).Selections,'region');
    fprintf('   %s selected\n',label);
    label=SMASH.Text.sprintPlural(report(n).Reductions,'reduction');
    fprintf('   %s generated\n',label);
end

end