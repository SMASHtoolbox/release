% SimpleNotes Simple note editor
%
% This *static* method creates a simple note editor.  The results are
% conceptually similar to MATLAB's inputdlg function with one multirow edit
% box, but improved font sizing makes for better readability.  The calling
% syntax is:
%    answer=Dialog.SimpleNotes(Prompt,Title,Size,default);
% using empty value placeholders to invoke standard values.  
%    -"Prompt" defines the text displayed above the edit box.  The standard
%    value is 'Notes:'.
%    -'Title" defines the text displayed on top of the dialog box.  The
%    standard value is 'Notes'.
%    -'Size' defines the edit box size in terms of [rows cols]; the
%    standard value is [10 40].  Scalar values are interpreted as the
%    number of rows with a 40 column box.  Note that the edit box may
%    horizontally accomodate for characters than the specified number of
%    columns when the default uicontrol font is proportional rather than
%    fixed width.
%    -'Default' defines the initial content of the edit box.  Character
%    arrays, strings, and cell arrays of characters may be specified.  The
%    standard value is an empty character array.
% The ouput "answer" is a character array extracted from the edit box when
% the "OK" button is pressed.  Closing the dialog or pressing the cancel
% button causes "answer" to be the number 1.
% 
% See also Dialog, inputdlg
%
function answer=SimpleNotes(Prompt,Title,Size,Default)

answer=0;

% manage input
if (nargin < 1) || isempty(Prompt)
    Prompt='Notes:';
else
    Prompt=SMASH.Text.text2char(Prompt,'ERROR: invalid prompt');
end

if (nargin< 2) || isempty(Title)
    Title='Notes';
else
    Title=SMASH.Text.text2char(Title,'ERROR: invalid prompt');
end

if (nargin < 3) || isempty(Size)
    Size=[10 40];
else
    ERRMSG='ERROR: invalid box size';
    assert(isnumeric(Size),ERRMSG);
    if isscalar(Size) % rows only
        Size(2)=40; 
    else
        assert(numel(Size) == 2,ERRMSG);
    end
    assert(all(Size > 0),ERRMSG);
    Size=round(Size);
end

if (nargin < 3) || isempty(Default)
    Default='';
else   
    try
        Default=char(Default);
    catch
        error('ERROR: invalid default text');
    end
end

% query local settings
s=settings;
fontsize= s.matlab.fonts.codefont.Size.ActiveValue;

% create dialog box
db=SMASH.MUI.Dialog('FontSize',fontsize);
db.Hidden=true;
db.Name=Title;

hEdit=addblock(db,'medit',Prompt,Size(2),Size(1));
set(hEdit(end),'String',Default);

button=addblock(db,'button',{'OK' 'Cancel'});
set(button(1),'Callback',@done);
    function done(varargin)
        answer=get(hEdit(end),'String');
        delete(button(1));
    end
set(button(2),'Callback',@cancel);
    function cancel(varargin)
        delete(button(1));
    end

locate(db,'center');
show(db);
db.Modal=true;
waitfor(button(1));
delete(db);

end