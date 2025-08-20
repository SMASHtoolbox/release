% CORRELATE Calculate correlation between two objects
%
% This methods correlates two Signal objects [?], creating a new object.
%    >> new=correlate(object,pattern);
% The new object inherits most of its properties from the first input.  As
% such, the second input should be used as the "pattern" signal.
%
% If no output is requested, the results are plotted in a new figure.
%
% See also Signal
%

%
% created November 15, 2013 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=correlate(object,pattern)

% verify uniform grid
object=makeGridUniform(object);

% handle input
if isnumeric(pattern)
    % do nothing
elseif isa(pattern,'SMASH.SignalAnalysis.Signal')
    pattern=makeGridUniform(pattern);
    dx1=object.Grid;
    dx1=(max(dx1)-min(dx1))/(numel(dx1)-1);
    dx2=pattern.Grid;
    dx2=(max(dx2)-min(dx2))/(numel(dx2)-1);
    dx=[dx1 dx2];
    if diff(dx)/mean(dx)>1e-6
        error('ERROR: object and pattern should have the same Grid spacing');
    end
    pattern=pattern.Data;
end

% perform correlation
Data=conv2(object.Data,pattern,'same');
[peak,Location]=max(Data);
Data=Data/peak;
Grid=object.Grid;
Location=Grid(Location);

% handle output
if nargout==0
    figure;
    plot(Grid,Data);
    xlabel(object.GridLabel);
    ylabel('Correlation');
    label=sprintf('Peak location=%#+g',Location);
    title(label);
end

if nargout>=1
    varargout{1}=struct('Grid',Grid,'Data',Data,'Location',Location);
end

end