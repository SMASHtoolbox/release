% ComplexQuestion Simple question dialog
%
% This static method generates a simple question dialog.
%   choice=Dialog.ComplexQuestion(question,title,list);
% The input "question" is the text shown in the dialog box; the input
% "title" in a short message at the top of that box.  The input "list"
% defines the permitted answers as a cell array of characters.  Each answer
% is shown as a push button.  
% 
% The output "choice" is answer selected by the end user.  An empty value is
% returned if the box is closed without pushing one of the answer buttons.
%
% Example:
%    list=cell(1,25);
%    for n=1:numel(list);
%       list{n}=sprintf('Chanel %d',n);
%    end
%    choice=Dialog.ComplexQuestion('Which channel?','Channel?',list);
%
% Optional arguments may be specified as name/value pairs after the list
% input.  Supported options include:
%    -FontSize (default value is 12 points)
%    -Rows (default value is 10)
%    -SelectMode (default value is 'single')
%
% See also Dialog
%

%
% created July 13, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=ComplexQuestion(question,title,list,varargin)

% manage input
assert(nargin > 0,'ERROR: no question specified');
if ischar(question)
    question={question};
else
    if isstring(question)
        question=cellstr(question);
    else
        assert(iscellstr(question),'ERROR: invalid question'); %#ok<ISCLSTR>
    end
end

if (nargin < 2) || isempty(title)
    title='Question';
else
    assert(ischar(title),'ERROR: invalid title');
end

if (nargin < 3) || isempty(list)
    list={'Yes' 'No'};
else
    if isstring(list)
        list=cellstr(list);
    end
    assert(iscellstr(list),'ERROR: invalid choices');
end

% manage options
Narg=numel(varargin);
assert(rem(Narg,2) == 0,'ERROR: unmatched name/value pair');
option.FontSize=12;
option.Rows=10;
option.SelectMode='single';
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'fontsize'
            assert(isnumeric(value) && (value > 0),...
                'ERROR: invalid font size');
            option.FontSize=value;
        case 'rows'
            assert(isnumeric(value) && (value >= 1),...
                'ERROR: invalid number of rows');
            option.Rows=round(value);
        case 'selectmode'
            assert(ischar(value),'ERROR: invalid select mode');
            switch lower(value)
                case {'single' 'multiple'}
                    % keep going
                otherwise
                    error('ERROR: invalid selection mode')
            end
            option.SelectMode=value;
        otherwise
            error('ERROR: invalid option name');
    end
end

% create dialog box
db=SMASH.MUI.Dialog('FontSize',option.FontSize);
db.Hidden=true;
db.Name=title;

hList=addblock(db,'list',question,list,[],option.Rows);
if strcmpi(option.SelectMode,'multiple')
    set(hList(2),'Max',2,'Min',0);
end
set(hList(2),'Callback',@doubleClick);
    function doubleClick(varargin)
        %disp(get(gcbf,'SelectionType'));
        if strcmpi(get(gcbf,'SelectionType'),'open')
            done();
        end
    end

button=addblock(db,'button',{'Done' 'Cancel'});
set(button(1),'Callback',@done);
    function done(varargin)
        choice=get(hList(2),'Value');
        choice=list(choice);        
        delete(db);
    end
set(button(2),'Callback',@cancel);
choice='';
    function cancel(varargin)
        delete(db);
    end

locate(db,'center');
db.Modal=true;
show(db);

waitfor(db.Handle);

% manage output
if nargout == 0
    fprintf('You selected "%s"\n',choice);
else
    varargout{1}=choice;
end


end