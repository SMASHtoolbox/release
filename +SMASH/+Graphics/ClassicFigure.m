% ClassicFigure Create classic MATLAB figure
%
% This function creates a classic MATLAB figure, placing axes control
% (zoom, pan, etc.) in a unified toolbar; vanishing axes toolbars are also
% disabled.
%    ClassicFigure();
%    fig=ClassicFigure(...);
%
% See also SMASH.Graphics
%

%
% created May 13, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=ClassicFigure(varargin)

% generate figure
try
    fig=figure(varargin{:});
catch ME
    throwAsCaller(ME);
end

% restore classic features
try
    addToolbarExplorationButtons(fig);
    set(fig,'defaultAxesCreateFcn',@(ax,~) set(ax.Toolbar,'Visible','off'));
catch    
end

% manage output
if nargout > 0
    varargout{1}=fig;
end

end