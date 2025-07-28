% coolwarm Generate cool/warm colormap
%
% This function generates the cool/warm colormap, described by Kenneth
% Moreland [1], for perceptual clarity.
%    map=coolwarm(); % 64 color levels
%    map=coolwarm(N); % N color levels
% The output "map" is a three-column table that can be used with MATLAB's
% colormap function.
%
% References: 
% [1] Kenneth Moreland, "Diverging Color Maps for Scientific
% Visualization", Proceedings of the 5th International Symposium on
% Visual Computing (2009).
%
% See also SMASH.MUI.Colormap, colormap, jet, parula
%

%
% created April 30, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=coolwarm(levels)

persistent red green blue
if isempty(red)
    file=fullfile(fileparts(mfilename('fullpath')),'data','coolwarm.txt');
    data=SMASH.FileAccess.readFile(file,'column');
    red=griddedInterpolant(data.Data(:,1),data.Data(:,2));
    green=griddedInterpolant(data.Data(:,1),data.Data(:,3));
    blue=griddedInterpolant(data.Data(:,1),data.Data(:,4));
end

% manage input
if (nargin < 2) || isempty(levels)
    levels=64;
else
    assert(SMASH.General.testNumber(levels,'positive','integer','notzero'),...
        'ERROR: invalid number of colormap levels');
end

x=linspace(0,1,levels);
x=x(:);
map=[red(x) green(x) blue(x)];

% manage output
if nargout > 0
    varargout{1}=map;
end

end