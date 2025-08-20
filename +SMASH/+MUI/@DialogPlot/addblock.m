% addblock Add control block
%
% This method adds control blocks to a dialog plot.  Each block is a
% set of controls (uicontrols) that are added to the dialog box
% sequentially, with the first block at the top and the last block at the
% bottom.  The dialog box is automatically resized to accomodate all
% control blocks as they are added.
% 
% The general syntax for this method is:
%    >> addblock(object,style,label,...);
% where the first two inputs (object and style) are mandatory).  Valid
% styles include 'text', 'edit', 'medit','button', 'toggle', 'check', 'radio',
% 'popup', 'listbox', 'edit_button', and 'edit_check'.  The third input,
% 'label', is generally recommended but optional.  Labels placement depends
% on the block style.
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
%    >> addblock(object,'listbox',label,choices,[mindwidth]);
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
% edit box and the second appears to the right of the edit box.
%
% A composite block is also provided for a popup next to a push button
% control.
%     >> h=addblock(object,'popup_button',label,choices,[minwidth]);
% In this case, the label should be a two-element cell array; the first
% element is the text label and the second element is the button label.
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
% See also DialogPlot
%

%
% created April 2, 2017 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=addblock(object,varargin)

assert(~object.Locked,'ERROR: block cannot be added to a finished dialog');

h=addblock(object.DialogBox,varargin{:});
N=numel(h);
new=nan(N,1);
for n=1:N
    new(n)=copyobj(h(n),object.ControlPanel);
end

set(object.ControlPanel,'Units','pixels');
PanelPosition=get(object.ControlPanel,'Position');
DialogPosition=get(object.DialogBox.Handle,'Position');
PanelPosition(3:4)=DialogPosition(3:4);
set(object.ControlPanel,'Position',PanelPosition);

try
    feval(get(object.Figure,'SizeChangedFcn'));
catch
    feval(get(object.Figure,'ResizeFcn'));
end

for n=1:numel(h)
    setappdata(h(n),'Copy',new(n));
    setappdata(new(n),'Source',h(n));
end

copy=get(object.ControlPanel,'Children');
for n=1:numel(copy)
    source=getappdata(copy(n),'Source');    
    set(copy(n),...
        'Position',get(source,'Position'),...
        'FontSize',get(source,'FontSize'));
end



if nargin > 0
   varargout{1}=new;
end

end