% ADDBLOCK Add control block to a Dialog
%
% This method adds control blocks to a custom dialog box.  Each block is a
% set of controls (uicontrols) that are added to the dialog box
% sequentially, with the first block at the top and the last block at the
% bottom.  The dialog box is automatically resized to accomodate all
% control blocks as they are added.
% 
% The general syntax for this method is:
%    >> addblock(object,style,label,...);
% where the first two inputs (object and style) are mandatory).  Valid
% styles include 'text', 'edit', 'cedit', 'medit','button', 'toggle',
% 'check', 'radio', 'popup', 'listbox', 'edit_button', and 'edit_check'.
% The third input, 'label', is generally recommended but optional.  Labels
% placement depends on the block style.
%   -Labels are placed inside 'text', 'button', and 'toggle' controls.
%   -Labels are placed above 'edit', 'medit', 'popup', and 'listbox' controls.
%   -Labels are placed next to 'check' and 'radio' controls (system dependent)
% Multiple labels may be specified for 'edit_button' and 'edit_check'
% blocks, each adhering to the above policy.
% 
% The simplest control block is 'text':
%    >> h=addblock(object,'text','Here is some text',[minwidth]);
% which adds a single line of text to the dialog box.  By default, the
% minimum width of the text box is determined from the label, but a minimum
% width (in characters) can be specified as an optional input.  The output
% variable "h" is graphic handle to the actual uicontrol.
%
% A similar syntax is used for 'edit' blocks.
%    >> h=addblock(object,'edit','Parameter: ',[minwidth]);
% The label 'Parameter: ' is placed *above* an empty edit box, the width of
% which is determined from the text label and "minwidth".  The output now
% contains two handles, one for the text label and the other for the edit
% box.  To create multi-line edit blocks, use 'medit'.
%    >> h=addblock(object,'medit','Parameter: ',minwidth,height);
% The 'cedit' block is a compact version of an edit block where the label
% and edit box are on the same line.
%    >> h=addblock(object,'cedit','Parameter: ',[minwidth]); 
% The input "minwidth" can be a scalar (shared) or two-element array (label
% edit) in a compact edit block.
%
% Push buttons, toggle buttons, check boxes, and radio buttons can be
% created individually:
%    >> addblock(object,'toggle',' Auto scale ');
%    >> addblock(object,'check',' Auto scale ',[minwidth]);
%    >> addblock(object,'radio',' Auto scale ',[minwidth]);
% or as part of a group.
%    >> h=addblock(object,'button',{' Apply ',' Close '}); % cell array label
% A single button/box per row is created in the first three examples, while
% the fourth example creates two buttons on the same row.  The width of
% each item is controlled by the label and a single minimum width
% specification (if present).  Additional white space in the label, as
% shown above, typically makes the label more visually pleasing across
% different computer systems.
%
% Popup and listbox blocks accept an additional parameter for "choices"
% that are to be displayed.
%    >> addblock(object,'popup',label,choices,[minwidth]);
%    >> addblock(object,'listbox',label,choices,[minwidth]);
% Choices should be specified as a cell array of text entries, such as 
% {'A' 'B' 'C'}.  Like all other blocks, a minimum width can be specified
% as the final input.
%
% Composite blocks provide an edit box next to a control.
%    >> addblock(object,'edit_button',label,[minwidth]);
%    >> h=addblock(object,'edit_check',label,[minwidth]);
% These blocks contain a text label, an empty edit box below the label, and
% a button or check box to the right of the edit box.  The "label" input
% should be a cell array with two text entries: the first appears above the
% edit box and the second appears to the right of the edit box.  Compact
% versions of each block ('cedit_button' and 'cedit_check') are also
% available.
%
% A composite block is also provided for a popup next to a push button
% control.
%     >> h=addblock(object,'popup_button',label,choices,[minwidth]);
% In this case, the label should be a two-element cell array; the first
% element is the text label and the second element is the button label.  A
% similar syntax works for list box next to a push button.
%    >> h=addblock(object,'listbox_button',label,choices,[minwidth],[height]);
%
% Table blocks allow for flexible display and interaction.
%     >> h=addblock(object,'table',label,[minwidth],[rows]);
% The input "label" (cell array) defines the number of table columns and
% their text labels.  For example, {'A' 'B' 'C'} generates a three-column
% table with the labels 'A', 'B', and 'C'.  The optional input "minwidth"
% defines the minimum character width for each column.
%     -A scalar indicates a common mimimum width for all columns.  Passing
%     a vector specifies a particular minimum width for each column.
%     -Columns are always sized to fit their label.  Any minimum width
%     smaller than the label width is ignored.
% The optional input "rows" indicates the number of displayed table rows.
%
% NOTE: single-line edit blocks support a fourth input that omits the text
% label above the edit box.
%    >> addblock(object,'edit','',minwidth,'skiplabel');
%    >> h=addblock(object,'edit','',minwidth,'skiplabel');
% In the second example, the first element of the output "h" is NaN,
% indicating that no text box was created.  Labels can also be suppressed
% in composite text boxes (button/check).
%
% See also Dialog, frame, probe
%

% created August 2, 2013 by Daniel Dolan (Sandia National Laboratories)
function varargout=addblock(object,style,varargin)

% handle input
if (nargin<2) || isempty(style)
    error('ERROR: no block style specified');
end

% handle input
if object.Locked
    fprintf('Control blocks cannot be added to a locked object\n');
    return
end

% call private method
switch lower(style)
    case 'text'
        h=text(object,varargin{:});
    case 'edit'
        h=edit(object,varargin{:});
    case 'cedit'
        h=cedit(object,varargin{:});
    case 'medit'
        h=medit(object,varargin{:});
    case {'button','buttons'}
        h=button(object,varargin{:});
    case {'check','checkbox'}
        h=check(object,varargin{:});
    case {'list','listbox'}
        h=listbox(object,varargin{:});
    case 'popup'
        h=popup(object,varargin{:});
    case 'radio'
        h=radio(object,varargin{:});
    case 'toggle'
        h=toggle(object,varargin{:});
    case 'edit_button'
        h=edit_button(object,varargin{:});
    case 'cedit_button'
        h=cedit_button(object,varargin{:});
    case 'edit_check'
        h=edit_check(object,varargin{:});
    case 'cedit_check'
        h=cedit_check(object,varargin{:});
    case 'popup_button'
        h=popup_button(object,varargin{:});
    case 'table'
        h=table(object,varargin{:});
    case 'slider'
        h=slider(object,varargin{:});
    case 'listbox_button'
        h=listbox_button(object,varargin{:});
    case 'custom'
        h=custom(object,varargin{:});
    otherwise
        error('ERROR: %s is not a supported dialog style',style);
end
% handle output
if nargout>=1
    varargout{1}=h;
end

end