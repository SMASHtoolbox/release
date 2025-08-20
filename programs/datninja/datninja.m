% datninja('ImageFile',file);
%
function varargout=datninja(varargin)

% manage input
ImageFile='';
FontSize=14;
assert(rem(nargin,2) == 0,'ERROR: unmatched name/value pair');
for n=1:2:nargin
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'imagefile'
            assert(logical(exist(value,'file')),...
                'ERROR: invalid image file');
            ImageFile=value;
        case 'fontsize'
            assert(isnumeric(value) && isscalar(value) && (value > 0),...
                'ERROR: invalid font size');
            FontSize=value;
        otherwise
            error('ERROR: "%s" is not a valid option');
    end
end

% create program
db=createGUI(FontSize);
if ~isempty(ImageFile)
    try
        session=getappdata(db.Figure,'Session');
        loadImage(session,ImageFile);
        hImage=findobj(db.Figure,'Type','image');
        set(hImage,'CData',session.Image,'Visible','on');
    catch ME
        throwAsCaller(ME);
    end
end

% manage output
if isdeployed
    varargout{1}=0;
end

end