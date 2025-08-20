% SELECT Select file/format for a CustomFile object
%
% Syntax:
%    >> object=select(object,[filename],[format]);
%
% see also FileAccess, read
%

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
    choice={'Ocean Optics measurement','Optronics Laboratory measurement','Optronics Laboratory screen dump'};
    short={'oceanoptics','optronicslab','optronicslabdump'};
    conversion=get(0,'ScreenPixelsPerInch');
    height=10/72*conversion; % assume 10 point font
    width=height/2;
    rows=numel(choice);
    cols=0;
    for n=1:rows
        cols=max(cols,numel(choice{n}));
    end
    [choice,ok]=listdlg('ListString',choice,...
        'PromptString','Select format:',...
        'Name','File format',...
        'SelectionMode','single',...
        'ListSize',[width*cols (height+2)*rows]);
    assert(ok==1,'ERROR: no format selected');    
    format=short{choice};
    
end
object.Format=format;

end