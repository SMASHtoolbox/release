function FontSize=determineFontSize(extra)

if (nargin < 1) || isempty(extra)
    extra=1;
else
    assert(isnumeric(extra) && isscalar(extra) && (extra > 0),...
        'ERROR: invalid extra scale factor');
end

report=SMASH.Graphics.DisplayTools.checkDisplay();
scale=1;
for n=1:numel(report)
    if report(n).Spawn
        scale=report(n).ActualResolution/report(n).SetResolution;
        break
    end
end

FontSize=get(0,'DefaultUIControlFontSize')*scale*extra;

end