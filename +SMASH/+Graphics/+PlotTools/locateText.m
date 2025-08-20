% locateText Locate text with respect to the current axes
%
% This function places text in specified locations with respect to the
% current axes.  The calling syntax is:
%    ht=locateText(entry,location);
% The input "entry" is text string (or cell array of text strings) to be
% placed.  The input "location" indicates where the string should be
% placed.  Valid locations include 'north', 'northwest', 'northeast',
% 'south', 'southeast', and 'southwest'.  The output "ht", if specified, is
% a graphic handle for the text object.
%
% The primary use of this function is to generate offset title labels in
% figures containing more than one axes.  Usually, these labels are located
% on the right hand side of the axes.
%    ht=locateText(label,'northwest');
%
% See also Graphics
%

%
% created April 26, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=locateText(entry,location,varargin)

% manage input
assert(nargin>=2,'ERROR: insufficient input');

assert(ischar(entry) || iscellstr(entry),...
    'ERROR: invalid text entry');

assert(ischar(location),'ERROR: invalid text location');
location=lower(location);

% set up and generate text
switch location
    case 'north'
        Position=[0.5 1];
        HorizontalAlignment='center';
        VerticalAlignment='bottom';
    case 'northeast'
        Position=[1 1];
        HorizontalAlignment='right';
        VerticalAlignment='bottom';
    case 'southeast'
        Position=[1 0];
        HorizontalAlignment='right';
        VerticalAlignment='top';
    case 'south'
        Position=[0.5 0];
        HorizontalAlignment='center';
        VerticalAlignment='top';
    case 'southwest'
        Position=[0 0];
        HorizontalAlignment='left';
        VerticalAlignment='top';
    case 'northwest'
        Position=[0 1];
        HorizontalAlignment='left';
        VerticalAlignment='bottom';
    otherwise
        error('ERROR: invalid text location');
end

htext=text('String',entry,...
    'Units','normalized','Position',Position,...
    'HorizontalAlignment',HorizontalAlignment,...
    'VerticalAlignment',VerticalAlignment,...
    varargin{:});

% manage output
if nargout>0
    varargout{1}=htext;
end

end