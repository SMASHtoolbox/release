% browseDrive Browse drive content
%
% This *static* method provides interactive dialog for browsing a system
% drive.
%    selection=Dialog.browseDrive;
% The output "selection" is a cell array of files/folders that are selected
% when the "OK" button is pressed.  The value 0 is returned when the
% "Cancel" button is pressed or the dialog box is closed.  
%
% The dialog lists the filtered content of the current drive location.  The
% current location can be manually changed from the top edit box.
% Double-clicking on the parent directory or any subdirectory moves the
% current location up or down, respectively.  Only files and subdirectories
% consisent with the name filter are displayed.  Individual and multiple
% content selections are permitted.
%
% Dialog customization is supported through optional name/value pairs.
%    selection=Dialog.browseDrive(name,value,...);
% Valid options include:
%   -'Name' is the dialog box name.  Default is 'Browse drive'.
%   -'Location' is starting location.  Default is the current directory.
%   -'Filter' is the content name filter.  Default value is '*'.
%   -'FontSize' is the control font size.  Default value is 12 (points).
%
% See also Dialog
%

function selection=browseDrive(varargin)

assert(rem(nargin,2) == 0,'ERROR: unmatched name/value pair');

% manage options
option.Name='Browse drive';
option.Location=pwd;
option.FontSize=12;
option.Filter='*';
for k=1:2:nargin
    name=varargin{k};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{k+1};
    switch lower(name)
        case 'name'
            if isstring(value)
                value=char(value(1));
            else
                assert(ischar(value),'ERROR: invalid name');
            end
            option.Name=value;
        case 'location'
            if isstring(value)
                value=char(value(1));
            else
                assert(ischar(value),'ERROR: invalid location');                
            end
            option.Location=value;
        case 'fontsize'
            assert(isnumeric(value) && isscalar(value)...
                && (value > 5) && (value < 100),...
                'ERROR: invalid font size');
            option.FontSize=value;
        case 'filter'
            if isstring(value)
                value=char(value(1));
            else
                assert(ischar(value),'ERROR: invalid file filter');
            end
            option.Filter=value;
        otherwise
            error('ERROR: invalid option')
    end
end

selection=0;

% create dialog box
dlg=SMASH.MUI.Dialog('FontSize',option.FontSize);
dlg.Hidden=true;
dlg.Name=option.Name;
width=40;

Directory=addblock(dlg,'edit','Location:',width);
set(Directory(1),'FontWeight','bold');

Filter=addblock(dlg,'edit','Filter:',width);
set(Filter(1),'FontWeight','bold');
set(Filter(end),'String',option.Filter);

temp={' '};
temp=repmat(temp,[15 1]);
Contents=addblock(dlg,'listbox','Content:',temp,width);
set(Contents(1),'FontWeight','bold');
set(Contents(end),'TooltipString',...
    'Double-click to open folders','Max',2);

Finish=addblock(dlg,'button',{' Done ' ' Cancel '});

% define callbacks
set(Directory(2),'Callback',@changeDirectory);
    function changeDirectory(varargin)
        target=get(Directory(2),'String');        
        try
            current=pwd;
            cd(target);
            target=pwd;
            cd(current);
        catch
            target=get(Directory(2),'UserData');
        end
        set(Directory(2),'String',target,'UserData',target);                
        updateContents();
    end

set(Contents(2),'Callback',@selectFile)
    function selectFile(varargin)
        selection=get(dlg.Handle,'SelectionType');
        if ~strcmpi(selection,'open')
            return
        end
        target=get(Directory(2),'String');
        list=get(Contents(2),'String');
        value=get(Contents(2),'Value');
        if strcmp(list{value},'(parent directory)')
            target=fileparts(target);
        else
            target=fullfile(target,list{value}); 
        end                      
        if isfolder(target)
            current=pwd;
            cd(target);
            target=pwd;
            cd(current);
            set(Directory(2),'String',target,'UserData',target);
            updateContents();
        end
    end

set(Filter(2),'Callback',@changeFilter)
    function changeFilter(varargin)
        updateContents();
    end

set(Finish(1),'Callback',@done);
    function done(varargin)
        target=get(Directory(2),'String');
        list=get(Contents(2),'String');
        value=get(Contents(2),'Value');                               
        selection=cell(size(value));
        for n=1:numel(value)
            selection{n}=fullfile(target,list{value});
        end        
        %source=fullfile(target,list{value});        
        delete(dlg);
    end

set(Finish(2),'Callback',@cancel);
    function cancel(varargin)
        delete(dlg);
    end

% helper functions
    function updateContents()        
        target=get(Directory(2),'String');
        filter=get(Filter(end),'String');
        file=dir(fullfile(target,filter));
        list{1}='(parent directory)';
        keep=false(size(file));
        for n=1:numel(file) % directories first
            if ~file(n).isdir
                keep(n)=true;               
            elseif file(n).name(1)=='.'
                % skip hidden folders
            else
                list{end+1}=sprintf('%s%s',file(n).name,filesep); %#ok<AGROW>                            
            end
        end
        file=file(keep);
        for n=1:numel(file) % files next
            if file(n).name(1) == '.'
                % skip hidden files
            else                
                list{end+1}=file(n).name; %#ok<AGROW>
            end
        end                      
        value=get(Contents(2),'Value');
        value=min(value,numel(list));
        set(Contents(2),'Value',value,'String',list);
        
    end

% finalize and display dialog box
set(Directory(2),'String',pwd,'UserData',pwd);
updateContents();

locate(dlg,'center');
dlg.Modal=true;
dlg.Hidden=false;

uiwait(dlg.Handle);

end