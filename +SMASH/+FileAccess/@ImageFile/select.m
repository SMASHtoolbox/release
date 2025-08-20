% SELECT Select file associated with an ImageFile object
%
% Syntax:
%    >> object=select(object,[filename],[format]);
%
% See also ImageFile, read
%
function object=select(object,filename,format)

if nargin<2
    filename='';
end

if nargin<3
    format='';
end


object=select@SMASH.FileAccess.File(object,filename);

if isempty(format)
    [~,~,ext]=fileparts(object.FileName);
    switch lower(ext)
        case '.spe'
            format='winspec';
        case '.imd'
            format='optronis';
        case '.img'
            format=chooseIMG;
        case '.pff'
            format='film';
        case '.hdf'
            format=SMASH.FileAccess.determineFormat(filename,{'film' 'sydor'});
        case ''
            format=SupportedFormats();
        otherwise
            format='graphics';
    end
end
object.Format=format;

    function format=SupportedFormats()
        
        % define all supported formats
        short={};
        full={};
                
        short{end+1}='film';
        full{end+1}='Film scans (*.img, *.hdf, *.pff)';
        
        short{end+1}='graphics';
        full{end+1}='Standard graphic files (*.jpg, *.tif, *.png, ...)';
        
        short{end+1}='hamamatsu';
        full{end+1}='Hamamatsu streak camera images (*.img)';
        
        short{end+1}='optronis';
        full{end+1}='Optronis streak camera images (*.imd)';
        
        short{end+1}='plate';
        full{end+1}='Image plate scans (*.img)';
        
        short{end+1}='sbfp';
        full{end+1}='Santa Barbara Focal Plane images (*.img)';
        
        short{end+1}='winspec';
        full{end+1}='WinSpec images (*.spe)';
        
        % prompt user to select format
        conversion=get(0,'ScreenPixelsPerInch');
        height=10/72*conversion; % assume 10 point font
        width=height/2;
        rows=numel(full);
        cols=0;
        for n=1:rows
            cols=max(cols,numel(full{n}));
        end
        [choice,ok]=listdlg('ListString',full,...
            'PromptString','Select format:',...
            'Name','File format',...
            'SelectionMode','single',...
            'ListSize',[width*cols (height+2)*rows]);
        assert(ok==1,'ERROR: no format selected');
        format=short{choice};
        
        % verify format selection
        format=lower(format);
        valid=false;
        for n=1:numel(short)
            if strcmp(format,short{n})
                valid=true;
                break
            end
        end
        assert(valid,'ERROR: invalid file format');
        
    end

end

function format=chooseIMG()

choice={'Film scan','Hamamatsu image','Image plate','Santa Barbara Focal Plane image'};
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Select format';
addblock(dlg,'listbox','Select *.img format',choice);
h=addblock(dlg,'button',{'Done'});
set(h,'Callback','delete(gcbo)');
dlg.Hidden=false;
waitfor(h);
try
    data=probe(dlg);
    delete(dlg);
catch
    error('ERROR: no format selected');
end
switch data{1}
    case choice{1}
        format='film';
    case choice{2}
        format='hamamatsu';
    case choice{3}
        format='plate';
    case choice{4}
        format='sbfp';
end

end