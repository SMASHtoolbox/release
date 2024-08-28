% Input Text input dialog
%
% This *static* method generates an input dialog for text input.
%    response=Dialog.Input(prompt,title,default);
% The input "prompt" is a cell/string array indicating the information a
% user is expected to provide.  Each prompt is displayed above an edit box
% for user responses.  The optional input "title" is the name of the dialog
% box.  The optional input "default" is a cell/string array of default
% responses, which must have the same number of elements as "prompt".
%
% The output "response" is a cell array of character strings.  When the
% user presses the OK button, each edit box is read in the order it was
% created, e.g. the response to prompt{1} is returned as response{1}.
% Pressing the Cancel button returns an empty cell array.  The dialog is
% automatically modal, and execution is suspended until the OK/Cancel
% buttons are pressed.
%
% Additional name/value inputs:
%    Dialog.Message(prompt, title,default,name,value,...);
% are passed as options (e.g., FontSize) for the Dialog class.
%
% See also Dialog
%
function response=Input(prompt,title,default,varargin)

% manage input
%assert(nargin > 0,'ERROR: no prompt specified');
if (nargin < 1) || isempty(prompt)
    prompt={'Prompt:'};
elseif ischar(prompt)
    prompt={prompt};
else
    assert(iscellstr(prompt) || isstring(prompt),...
        'ERROR: invalid message');
end

if (nargin < 2) || isempty(title)
    title='';
else
    assert(ischar(title),'ERROR: invalid title');
end

if (nargin < 3) || isempty(default)
    default=cell(size(prompt));
else
    assert(iscellstr(default) || isstring(default),...
        'ERROR: invalid default');    
end

% create dialog box
db=SMASH.MUI.Dialog(varargin{:});
db.Hidden=true;
db.Name=title;

N=numel(prompt);
width=20;
for n=1:N
    width=max(width,numel(prompt{n}));
    width=max(width,numel(default{n}));
end

for n=1:N
    h=addblock(db,'edit',prompt{n},width);
    set(h(2),'String',default{n});
end

button=addblock(db,'button',{'OK' 'Cancel'});
set(button(1),'Callback',@ok);
    function ok(varargin)
        response=probe(db);
        delete(db);
    end
set(button(2),'Callback',@cancel);
    function cancel(varargin)
        delete(db);
    end

% wait for user
response={};
show(db);

db.Modal=true;
uiwait(db.Handle);

end