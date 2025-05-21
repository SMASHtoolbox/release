% generate Generate PDF file
%
% This *static* method generates a PDF file from an existing figure.
%    PDFfile.generate(file,name,value,...);
% The mandatory input "file" indicates the PDF file name.  Optional
% name/value pairs define file settings.
%    -'Figure' controls which figure is used (default is current figure).
%    -'Resolution' controls how the figure is rendered.  When omitted or set
%    to empty, the figure is rendered as vector graphic.  Specifying a
%    number, such as 300, renders the figure as an image at that DPI setting.
%    -'Paper' controls paper sizing.  When omitted or set to 'auto', the
%    paper is automatically sized to accomodate the figure.  Standard paper
%    sizes, such as 'usletter' or 'A4', can also be used.  Custom sizing is
%    specified by width/height/unit, such as '8.5 x 11 in', ignoring
%    extraneous white space.  Valid units are 'in' and 'cm'.
% The print function is used for standard figures. The exportgraphics
% function is used for uifigures in release 2020a or later; an error is
% generated in earlier releases.
%
% See also PDFfile, print
%

function generate(file,varargin)

current=get(groot,'CurrentFigure');
assert(isvalid(current),'ERROR: no figure available');

% manage file name
assert(nargin >= 1,'ERROR: no file specified');
[~,~,ext]=fileparts(file);
assert(strcmpi(ext,'.pdf'),'ERROR: invalid file extension');
try
    fid=fopen(file,'w');
    fclose(fid);
catch
    error('ERROR: invalid file name');
end

% manage options
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
option.Figure=current;
option.Resolution=[];
option.Paper='auto';
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'figure'
            if isnumeric(value)
                number=value;
                value=findall(groot,'Type','Figure','Number',number);
                assert(~isempty(value),'ERROR: figure %d does not exist',number);
            else
                assert(isscalar(value) && ishandle(value) && isvalid(value),...
                    'ERROR: invalid figure handle');
            end
            option.Figure=value;
        case 'resolution'
            assert(isnumeric(value) && (value > 25),'ERROR: invalid resolution');
            option.Resolution=value;
        case 'paper'
            assert(ischar(value),'ERROR: invalid paper setting');
            option.Paper=value;
        otherwise
            error('ERROR: %s is not a valid option',name);
    end
end

% generate PDF
if matlab.ui.internal.isUIFigure(option.Figure)
    assert(logical(exist('exportgraphics','file')),...
        'ERROR: cannot generate PDF from uifigure in this MATLAB release');
    argument{1}=option.Figure;
    argument{end+1}=file;  
    argument{end+1}='ContentType';
    if isempty(option.Resolution)
        argument{end+1}='vector';
    else
        argument{end+1}='image';
        argument{end+1}='Resolution';
        argument{end+1}=ceil(option.Resolution);
    end
    exportgraphics(argument{:});
else
    sizePaper(option);
    argument{1}=file;
    argument{end+1}=option.Figure;
    argument{end+1}='-dpdf';
    if isempty(option.Resolution)
        argument{end+1}='-painters';
    else
        argument{end+1}='-opengl';
        argument{end+1}=sprintf('-r%.0f',option.Resolution);
    end
    argument{end+1}='-bestfit';
    print(argument{:});
end

end

function sizePaper(option)

if strcmpi(option.Paper,'auto')
    old=get(option.Figure,'Units');
    set(option.Figure,'Units','inches');    
    position=get(option.Figure,'Position');   
    set(option.Figure,'Units',old,...
        'PaperUnits','inches','PaperSize',position(3:4));
else    
    unit='';
    width=nan(1,2);
    index=1;
    name=option.Paper;
    while ~isempty(name)
        if any(isnan(width))
            [value,~,~,next]=sscanf(name,'%g',1);
            name=name(next:end);
            if isempty(value)
                name=name(2:end);
            else
               width(index)=value;
               index=index+1;
            end
            continue
        end
        unit=sscanf(name,'%s',1);
        break       
    end
    if any(isnan(width))
        try
            set(option.Figure,'PaperType',option.Paper);
        catch ME
            throwAsCaller(ME);
        end
    else
        switch lower(unit)
            case {'in' 'inches'}
                set(option.Figure,'PaperUnits','inches');
            case {'cm' 'centimeters'}
                set(option.Figure,'PaperUnits','centimeters');
            otherwise
                error('ERROR: invalid paper units');
        end
        assert(all(width > 0),'ERROR: invalid paper size');
        set(option.Figure,'PaperSize',width);
    end
end

end