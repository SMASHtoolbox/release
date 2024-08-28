% Message Basic message dialog
%
% This static method generates a basic message dialog.
%   Dialog.Message(message,title,width);
% The "message" input is required and may be text or a cell array of text
% arrays.  The "title" input is an optional string shown at the top of
% dialog.  The optional "width" input defines the minimum width of the
% dialog, wrapping wide messages as necessary.  
%
% Additional name/value inputs:
%    Dialog.Message(message,title,width,name,value,...);
% are passed as options (e.g., FontSize) for the Dialog class.
%
% Requesting outputs for this method:
%    [fig,db]=Dialog.Message(...);
% returns the figure handle and Dialog object.
%
% See also Dialog
%

%
% created October 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=Message(message,title,width,varargin)

% manage input
assert(nargin > 0,'ERROR: no message specified');
if ischar(message)
    message={message};
else
    assert(iscellstr(message),'ERROR: invalid message');
end

if (nargin < 2) || isempty(title)
    title='';
else
    assert(ischar(title),'ERROR: invalid title');
end

if (nargin < 3) || isempty(width)
    width=0;
    for n=1:numel(message)
        width=max(width,numel(message{n}));
    end
else
    assert(SMASH.General.testNumber(width,'integer','positive','notzero'),...
        'ERROR: invalid width');
end

% create dialog box
db=SMASH.MUI.Dialog(varargin{:});
db.Hidden=true;
db.Name=title;

h=addblock(db,'text','dummy',width);
h.String=textwrap(h,message);
h.Position(3:4)=h.Extent(3:4);
make_room(db);

% manage output
if nargout == 0
    locate(db,'center');
else
    varargout{1}=db.Handle;
    varargout{2}=db;
end
db.Hidden=false;

end