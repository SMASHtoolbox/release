% SimpleQuestion Simple question dialog
%
% This *static* method generates a simple question dialog.
%   choice=Dialog.SimpleQuestion(question,title,list);
% The input "question" is the text shown in the dialog box; the input
% "title" in a short message at the top of that box.  The input "list"
% defines the permitted answers as a cell array of characters.  Each answer
% is shown as a push button.  The output "choice" is answer selected by the
% end user.  An empty value is returned if the box is closed without
% pushing one of the answer buttons.
%
% Example:
%    choice=Dialog.SimpleQuestion('Should we continue?','Continue?',{'Yes','No'});
%
% Optional arguments may be specified as name/value pairs after the list
% input.  Supported options include FontSize.
%
% See also Dialog
%

%
% created July 13, 2019 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=SimpleQuestion(question,title,list,varargin)

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
for n=1:2:Narg
    name=varargin{n};
    assert(ischar(name),'ERROR: invalid option name');
    value=varargin{n+1};
    switch lower(name)
        case 'fontsize'
            assert(isnumeric(value) && (value > 0),...
                'ERROR: invalid font size');
            option.FontSize=value;
        otherwise
            error('ERROR: invalid option name');
    end
end

% create dialog box
db=SMASH.MUI.Dialog('FontSize',option.FontSize);
db.Hidden=true;
db.Name=title;

addblock(db,'text',question);

h=addblock(db,'button',list);
set(h,'Callback',@select);
choice='';
    function select(src,varargin)
        choice=get(src,'String');
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