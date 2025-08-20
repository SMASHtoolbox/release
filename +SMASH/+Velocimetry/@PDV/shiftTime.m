% shiftTime Shift time data
%
% This method shifts time data in a PDV object.
%    object=shiftTime(object,value);
% Time shifts are performed in an additive manner:
%    time=0 becomes time=value
% Previous shifts is removed each time this method is called, so sequential
% time shifts are *not* cumulative.
%
% The input "value" can be a scalar or numeric array.  The former indicates
% a common time shift applied to all channels, while the latter indicates
% channel-specific shifts.  Specifying no values:
%    object=shiftTime(object);
% launches an interactive selection dialog.
%
% NOTE: time shifting alters measurement channels, reference/ROI
% selections, and history data.  Channel-specific time shifts make history
% data obsolete.
% 
% See also PDV, scaleTime
%

%
% created February 11, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function object=shiftTime(object,value)

persistent legacy
if isempty(legacy)
    %legacy=true(); 
    switch lower(SMASH.Graphics.checkGraphics())
        case 'java'
            legacy=true();
        case 'javascript'
            legacy=false();
    end
end

previous=object.TimeShift;

% manage input
if nargin < 2 % interactive mode
    if legacy
        value=chooseShiftLegacy(previous,object.Name);
    else
        value=chooseShift(previous,object.Name);
    end
    if isempty(value)
        return
    end
elseif isnumeric(value)
    if isscalar(value)
        value=repmat(value,size(object.Channel));
    else
        assert(numel(value) == object.NumberChannels,...
            'ERROR: invalid number of shift values');
        value=reshape(value,size(object.Channel));
    end
else
    error('ERROR: invalid shift value')
end

% common shift test
if isscalar(value) || all(value(2:end) == value(1))
    CommonShift=true;
else
    CommonShift=false;
end

% account for previous value
object.TimeShift=value;
value=value-previous;

% perform time shifting
for n=1:object.NumberChannels
    object.Channel{n}.Measurement=shift(...
        object.Channel{n}.Measurement,value(n));
    if ~isempty(object.PrivateSpectrogram)
        object.PrivateSpectrogram{n}=shift(object.PrivateSpectrogram{n},...
            'Grid1',value(n));
    end
end

object.ReferenceSelection=object.ReferenceSelection+value(1);
if CommonShift
    for k=1:numel(object.ROIselection)
        table=object.ROIselection(k).Data;
        table(:,1)=table(:,1)+value;
        object.ROIselection(k)=define(object.ROIselection(k),table);
    end
    for n=1:object.NumberHistories
        object.History{n}=shift(object.History{n},value);
    end
else
    if ~isempty(object.ROIselection)
        warning('PDV:multiShift','Channel-specific shifting not applied to ROI selection(s)')
    end
    object.History=[];
    if strcmpi(object.Status.History,'complete')
        warning('PDV:multiShift',...
            'Channel-specific shifting resets histories');
    end
    object=changeStatus(object,'obsolete','History');
end

end

%%
function value=chooseShiftLegacy(previous,name)

db=SMASH.MUI.Dialog();
db.Hidden=true;
db.Name='PDV time shift';

h=addblock(db,'text',name,20);
set(h,'FontWeight','bold');

N=numel(previous);
for n=1:N
    h=addblock(db,'edit',sprintf('Channel %d shift:',n),20);
    EditBox(n)=h(2); %#ok<AGROW>
    temp=sprintf('%g',previous(n));
    set(h(2),'String',temp,'UserData',temp,'Callback',@checkValue);
end

CommonCheck=addblock(db,'checkbox','Common shift');
set(CommonCheck,'Callback',@changeCommon);
if N == 1
    set(CommonCheck,'Enable','off');
end

button=addblock(db,'button',{'OK' 'Cancel'});
set(button(1),'Callback',@ok);
set(button(2),'Callback',@cancel);

value=[];
locate(db,'center');
db.Modal=true;
show(db);
waitfor(button(1));
delete(db);

    function checkValue(src,~)
        temp=get(src,'String');
        [junk,~,~,next]=sscanf(temp,'%g',1);
        if isempty(junk)
            set(src,'String',get(src,'UserData'));
        else        
            temp=temp(1:(next-1));
            set(src,'String',temp,'UserData',temp);
        end
        if get(CommonCheck,'value')
            for nn=2:numel(EditBox)
                set(EditBox(nn),'String',get(EditBox(1),'String'));
            end
        end
    end
    function changeCommon(varargin)
        if get(CommonCheck,'Value')
            temp=get(EditBox(1),'String');
            set(EditBox,'String',temp,'UserData',temp);
            set(EditBox(2:end),'Enable','off');
        else
            set(EditBox(2:end),'Enable','on');
        end
    end
    function ok(varargin)
        temp=probe(db);
        temp=temp(1:end-1);
        value=zeros(size(temp));
        for nn=1:numel(temp)
            value(nn)=sscanf(temp{nn},'%g',1);
        end
        delete(button(1));
    end
    function cancel(varargin)
        delete(button(1));
    end

end

%%
function value=chooseShift(previous,name)

cb=SMASH.MUI2.ComponentBox();
setName(cb,'PDV time shift');

h=addMessage(cb,numel(name));
set(h,'FontWeight','bold','Text',name);
newRow(cb);

setLabelPosition(cb,'above');
N=numel(previous);
for n=1:N
    h=addEdit(cb,15);
    set(h(1),'Text',sprintf('Channel %d shift:',n));
    if n == 1
        EditBox=repmat(h(2),[1 N]);
    else
        EditBox(n)=h(2);
    end
    temp=sprintf('%g',previous(n));
    set(h(2),'Value',temp,'UserData',temp,'ValueChangedFcn',@checkValue);
end
newRow(cb);

label='Common shift';
CommonCheck=addCheckbox(cb,numel(label));
set(CommonCheck,'Text',label,'ValueChangedFcn',@changeCommon);
if N == 1
    set(CommonCheck,'Enable','off');
end
newRow(cb);

button(1)=addButton(cb,6);
set(button(1),'Text','OK','ButtonPushedFcn',@ok);
button(2)=addButton(cb,6);
set(button(2),'Text','Cancel','ButtonPushedFcn',@cancel);

value=zeros(1,N);
fit(cb);
locate(cb,'center');
setWindowStyle(cb,'modal');
show(cb);
waitfor(button(1));
delete(cb);

    function checkValue(src,~)
        temp=get(src,'Value');
        [junk,~,~,next]=sscanf(temp,'%g',1);
        if isempty(junk)
            set(src,'Value',get(src,'UserData'));
        else        
            temp=temp(1:(next-1));
            set(src,'Value',temp,'UserData',temp);
        end
        if get(CommonCheck,'value')
            for nn=2:numel(EditBox)
                set(EditBox(nn),'Value',get(EditBox(1),'Value'));
            end
        end
    end
    function changeCommon(varargin)
        if get(CommonCheck,'Value')
            temp=get(EditBox(1),'Value');
            set(EditBox,'Value',temp,'UserData',temp);
            set(EditBox(2:end),'Enable','off');
        else
            set(EditBox(2:end),'Enable','on');
        end
    end
    function ok(varargin)
        for nn=1:N
            value(nn)=sscanf(EditBox(nn).Value,'%g');
        end        
        delete(button(1));
    end
    function cancel(varargin)
        delete(button(1));
    end
end