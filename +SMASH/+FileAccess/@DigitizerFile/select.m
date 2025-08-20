% SELECT Select file/format for a DigitizerFile object
%
% Syntax:
%    >> object=select(object,[filename],[format]);
%
% see also FileAccess, probe, read
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
    [~,~,ext]=fileparts(object.FileName);
    switch lower(ext)
        case '.h5'
            %format='agilent';
            format=chooseH5;
        case '.hdf'
            %format='zdas';
            % format='saturn';
            choices={'ZDAS','SATURN'};
            [selection,ok]=listdlg('ListString',choices,...
                'SelectionMode','single',...
                'Name','Select format',...
                'PromptString','Select *.hdf format');
            if ok
                switch selection
                    case 1
                        format='zdas';
                    case 2
                        format='saturn';
                end
            else
                error('ERROR: no format selected');
            end            
        case '.trc'
            format='lecroy';
        case '.wfm'
            choices={'Tektronix','Yokogawa'};
            [selection,ok]=listdlg('ListString',choices,...
                'SelectionMode','single',...
                'Name','Select format',...
                'PromptString','Select *.wfm format');
            if ok
                switch selection
                    case 1
                        format='tektronix';
                    case 2
                        format='yokogawa';
                end
            else
                error('ERROR: no format selected');
            end
        case '.isf'
            format='tektronix';
        otherwise
            format=SupportedFormats();
    end
end
object.Format=format;

end

%% local utilities
function format=SupportedFormats()

% define all supported formats
short={};
full={};

short{end+1}='agilent';
full{end+1}='Agilent binary signals (*.h5)';

short{end+1}='keysight';
full{end+1}='Keysight binary signals (*.h5)';

short{end+1}='lecroy';
full{end+1}='LeCroy binary signals (*.trc)';

short{end+1}='tektronix';
full{end+1}='Tektronix binary signals (*.wfm, *.isf)';

%short{end+1}='yokogawa';
%full{end+1}='Yokogawa binary signals (*.wfm)';

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

function format=chooseH5()

choice={'Acqiris digitizers' 'Agilent digitizer' 'Keysight digitizer'};
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Select format';
addblock(dlg,'listbox','Select *.h5 format',choice);
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
        format='acqiris';
    case choice{2}
        format='agilent';
    case choice{3}
        format='keysight';
end

end