% VIEW Image visualization
%
% This method provides several types of visualization for Image objects.
% By default:
%    >> view(object);
% the objected is displayed as a single image in a new figure; a graphic
% handle can be passed to render the image in a specific location.
%    >> view(object,gca); % show image in current axes
% The standard view shows the image with a colorbar and uses labels
% specified in the object.
%
% A detailed view of the full image with an adjustable subregion
% can be created as shown below.
%    >> view(object,'detail'); % create new figure
%    >> view(object,'detail',fig); % draw in exiting figure
% The detail region can be moved by clicking on the full image or by
% pressing the direction keys.  To change the size of this region, press a
% direction key while holding down the shift key.
%
% An interactive view with vertical and horizontal cross sections is also
% provided.
%    >> view(object,'explore');
% Clicking on the main image or pressing the direction keys moves cross
% section location.
%
% In all cases, graphic handles created by the method are
% returned as a structure.
%    >> h=view(...);
%
% See also Image, slice

%
% created November 25 2013 by Daniel Dolan (Sandia National Laboratories)
%
%function varargout=view(object,varargin)
function varargout=view(object,mode,target)

% verify uniform grid
object=makeGridUniform(object);

% handle input
if (nargin<2) || isempty(mode)
    mode='show';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
switch mode
    case {'show','explore','detail','surface'}
        % do nothing
    otherwise
        error('ERROR: invalid view mode');
end

if nargin<3
    target=[];
end

% call the appropriate method
if ~isreal(object.Data)
    assert(strcmp(mode,'show'),'ERROR: %s mode requires real Data',mode);
    object.DataScale='linear';
    object.DataLim='auto';
    name=object.GraphicOptions.Title;
    data=object.Data;
    %h=basic_figure;
    fig=SMASH.MUI.Figure;
    h.fig=fig.Handle;
    set(h.fig,'Name','Complex Image view');
    ha(1)=subplot(1,2,1);
    object.Data=real(data);
    object.GraphicOptions.Title=sprintf('Real part of "%s"',name);
    show(object,ha(1));
    ha(2)=subplot(1,2,2);
    object.Data=imag(data);
    object.GraphicOptions.Title=sprintf('Imaginary part of "%s"',name);
    show(object,ha(2));
    linkaxes(ha,'xy');
elseif strcmp(mode,'show')
    h=show(object,target);
elseif strcmp(mode,'explore')
    h=explore(object);
elseif strcmp(mode,'detail')
    h=detail(object,target);
elseif strcmpi(mode,'surface')
    h=surface(object,target);
end

% handle output
if nargout>=1
    varargout{1}=h;
end

end