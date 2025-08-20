% setFonts Control figure fonts
%
% This function controls the font settings used in *new* figures; Font
% settings are specified in name/value pairs.
%    setFonts(name,value,...);
% There are roughly 60 font settings across the various graphic objects
% that can appear in a figure, but most of these fall into recurring
% categories.  Fonts associated with axes objects are controlled by
% AxesFontName, AxesFontSize, AxesFontUnits, AxesFontWeight, and
% AxesFontAngle; similar settings are avaible for text, uicontrol, uipanel,
% and uitable objects.  Font settings can be set individually or across a
% particular category.  For example:
%    setFonts('FontSize',20);
% defines a common font size for all objects that have a matching setting
% (AxesFontSize, TextFontSize, etc.).
%
% Font sizing can be specified in terms of N rows that fit on the primary
% display.
%    setFont('rows',N);
% This command applies a common font size (in pixels) to all graphic
% objects.
%
% MATLAB's default font settings can also be restored.
%    setFonts('factory');
% NOTE: default settings may vary with operating system.
%
% Requesting an output returns a structure of font settings.
%    setting=setFonts(...);
% Passing this structure back to the function restores a previous setting.
%    setFonts(settings);
%
% <a href="matlab:SMASH.System.showExample('setFonts','+SMASH/+MUI')">Examples</a>
%
%
% See also SMASH.MUI
%

%
% created March 22, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=setFonts(varargin)

% generate setting list
setting=generateSetting('default');

% manage input
if (nargin == 1) && strcmpi(varargin{1},'factory')   
    setting=generateSetting('factory');
              
elseif (nargin == 1) && isstruct(varargin{1})
    setting=varargin{1};
else
    assert(rem(nargin,2) == 0,'ERROR: unmatched name/value pair');
    name=fieldnames(setting);
    for m=1:2:nargin
        assert(ischar(lower(varargin{m})),'ERROR: invalid setting name');
        if strcmpi(varargin{m},'rows')
            rows=varargin{m+1};
            assert(SMASH.General.testNumber(rows,'positive') && (rows > 10),...
                'ERROR: invalid number of rows');
            ScreenSize=get(groot,'ScreenSize');
            FontSize=floor(ScreenSize(4)/rows);
            packtools.call('setFonts','FontUnits','pixels');
            packtools.call('setFonts','FontSize',FontSize);
            setting=generateSetting('default');
            continue
        end
        match=false;
        for n=1:numel(name)
            if ~endsWith(name{n},varargin{m},'IgnoreCase',true)
                continue
            end                        
            setting.(name{n})=varargin{m+1};                        
            match=true;
        end
        assert(match,'ERROR: %s is not a valid setting',varargin{m});
    end
end

% update settings
name=fieldnames(setting);
for n=1:numel(name)    
    try
        full=sprintf('Default%s',name{n});
        set(groot,full,setting.(name{n}));
    catch
        error('ERROR: invalid %s value',name{n});
    end    
end

% manage output
if nargout > 0
    varargout{1}=setting;
end

end

function setting=generateSetting(type)

persistent MasterList
if isempty(MasterList)
    MasterList=struct();
    data=get(groot,'factory');
    name=fieldnames(data);
    for n=1:numel(name)
        if isempty(regexpi(name{n},'font'))
            continue
        end
        short=name{n}(8:end);
        MasterList.(short)=data.(name{n});
    end
    
end

switch lower(type)
    case 'factory'
        setting=MasterList;
    otherwise
        setting=struct();
        name=fieldnames(MasterList);
        for n=1:numel(name)
            full=sprintf('Default%s',name{n});
            setting.(name{n})=get(groot,full);
        end       
end

end