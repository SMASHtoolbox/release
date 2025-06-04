% view Display scan
%
% This method displays a LUNA scan as a line plot in a new figure
%    view(object);
%    h=view(object); % return graphic handle
%
%
% See also LUNA
%

%
% created April 29, 2015 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,units)

% manage input
if (nargin < 2) || isempty(units)
    units='nanoseconds';
else
    assert(ischar(units),'ERROR: invalid units');
end
switch lower(units)
    case 'nanoseconds'
        x=object.Time;
        label='Round trip time (ns)';
    case 'meters'
        x=object.Distance;
        label='Distance (m)';
    case 'feet'
        x=object.Distance*3.28084;
        label='Distance (ft)';
    case 'inches'
        x=object.Distance*1e3/25.4;
        label='Distance (in)';        
    case 'millimeters'
        x=object.Distance*1e3;
        label='Distance (mm)';
    otherwise
        error('ERROR: invalid units');
end
y=object.LinearAmplitude;

% generate plot
SMASH.MUI.Figure();
h=plot(x,y);
xlabel(label);
ylabel('Linear return (1/ns)');
set(gca,'YScale','log');

if object.IsModified
    label=sprintf('Measurement file: %s (modified)',object.SourceFile);
else
    label=sprintf('Measurement file: %s',object.SourceFile);
end
title(label,'Interpreter','none');

% manage output
if nargout > 0
    varargout{1}=h;
end

end