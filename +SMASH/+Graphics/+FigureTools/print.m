% print Print figure to a graphic file
%
% This function prints a MATLAB figure to a graphic file.  The output file
% name must be explicitly specified.
%    print(filename);
% The output format is determined from the file extension.
%    *.eps         : Encapsulated PostScript file
%    *.jpg, *.jpeg : Joint Photographic Experts Group file
%    *.pdf         : Portable Document Format file
%    *.png         : Portabe Network Graphic file
%    *.tif, *.tiff : Tagged Image File Format file
% Vector formats (*.pdf and *.eps) are recommended for figures containing
% mostly lines and text.  Bitmap formats (*.jpg, *.png, and *.tif)
% recommended for figures containing very large images.
%
% Print options are specified as name/value pairs after the file name.
%    print(filename,name,value,...);
% Supported options include:
%    resolution : Bitmap image resolution in dots per inch (default is 300)
%    gui        : Shows or suppress GUI controls (default is 'on')
% For example:
%    print('myfile.png','resolution',300);
% prints a figure to *.png file at 300 DPI; GUI controls are displayed (if
% present).
%
% By default, this figure prints the current figure. Passing a graphic
% handle prints a specific figure.
%    print(fig,...);
%
% See also SMASH.Graphics.FigureTools, clip
%

%
% created January 20, 2016 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=print(varargin)

% manage input
assert(nargin>=1,'ERROR: insufficient input');

if ishandle(varargin{1})
    type=get(varargin{1},'Type');
    assert(strcmpi(type,'figure'),'ERROR: invalid figure handle');
    fig=varargin{1};
    varargin=varargin(2:end);
else
    fig=gcf;
end

filename=varargin{1};
assert(ischar(filename),'ERROR: invalid file name');
varargin=varargin(2:end);

Narg=numel(varargin);
assert(rem(Narg,2)==0,'ERROR: unmatched name/value pair');
option=struct('resolution',300,'color','on','gui','on');
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    name=lower(name);
    value=varargin{n+1};
    switch name        
        case 'resolution'
            assert(isnumeric(value) && isscalar(value),...
                'ERROR: invalid resolution value');
            if value<50
                warning('FigureTools:print',...
                    'Very low figure resolution requested');
            elseif value>1200
                warning('FigureTools:print',...
                    'Very high figure resolution requested');
            end
        case 'color'
            assert(ischar(value),'ERROR: invalid color mode');
            value=lower(value);
            assert(strcmp(value,'on') || strcmp(value,'off'),...
                'ERROR: invalid color mode');        
        case 'gui'
            assert(ischar(value),'ERROR: invalid GUI mode');
            value=lower(value);
            assert(strcmp(value,'on') || strcmp(value,'off'),...
                'ERROR: invalid GUI mode');
        otherwise
            error('ERROR: "%s" is an invalid option name');
    end
    option.(name)=value;
end

% print file based on extenstion
set(fig,'PaperPositionMode','auto');

resolution=sprintf('-r%g',option.resolution);

[~,~,ext]=fileparts(filename);
switch lower(ext)
    case '.eps'
        switch option.color
            case 'on'
                format='-depsc';
            case 'off'
                format='-deps';
        end   
        arg={fig format  '-loose' resolution filename};
    case {'.jpg' '.jpeg'}        
        format='-djpeg';
        arg={fig format  resolution filename};
    case '.pdf'
        format='-dpdf';
        arg={fig format  resolution filename};
        units=get(fig,'Units');
        paperunits=get(fig,'PaperUnits');
        set(fig,'Units',paperunits);
        pos=get(fig,'Position');
        set(fig,'PaperSize',pos(3:4));
        set(fig,'Units',units);
    case '.png'
        format='-dpng';
        arg={fig format  resolution filename};
    case {'.tif' '.tiff'}
        format='-dtiff';
        arg={fig format  resolution filename};
    otherwise
        error('ERROR: invalid file extension');
end

if strcmp(option.gui,'off')
    arg{end+1}='';
    arg(4:end+1)=arg(3:end);
    arg{3}='-noui';
end

print(arg{:});

% manage output
if nargout>0
    varargout{1}=arg;
end

end