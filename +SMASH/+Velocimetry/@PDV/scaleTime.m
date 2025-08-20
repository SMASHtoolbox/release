% scaleTime Scale time data
%
% This method scales all time data in a PDV object.
%    object=scaleTime(object,value);
% Digitizer measurements are typically recorded in seconds, so a scale
% value of 1e9 transforms the time base to nanoseconds.  The same scaling
% is applied to all time parameters: partition duration/advance, reference
% time range, and so forth.
%
% Frequency values are inversely scaled at the same time.  For example, the
% conversion of seconds to nanoseconds automatically transforms hertz to
% gigahertz.  Inverse scaling is automatically applied to all frequency
% values: offsets, ROI selections, etc.
%
% NOTE: time scaling also changes the Wavelength property, e.g. meters
% becomes nanometers, to maintain consistent velocities.  Wavelength
% property modifications, if needed, should be performed after calling this
% method.
%
% A common scale factor is typically applied to all measurement channels,
% but this is not strictly mandatory.  Passing an array of scale values
% allows each channel to be modified independently, forcing history data to
% become obsolete.
%
% See also PDV, shiftTime
%

function object=scaleTime(object,value)

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

previous=object.TimeScale;

% manage input
if nargin < 2 % interactive mode
    if legacy
        value=chooseScaleLegacy(previous,object.Name);
    else
        value=chooseScale(previous,object.Name);
    end
    if isempty(value)
        return
    end
elseif isnumeric(value) && all(value > 0)
    if isscalar(value)
        value=repmat(value,size(object.Channel));
    else
        assert(numel(value) == object.NumberChannels,...
            'ERROR: invalid number of scale values');
        value=reshape(value,size(object.Channel));
    end
else
    error('ERROR: invalid scale value')
end

% common shift test
if isscalar(value) || all(value(2:end) == value(1))
    CommonScale=true;
else
    CommonScale=false;
end

% account for previous value
object.TimeScale=value;
value=value./previous;

% perform time scaling
for n=1:object.NumberChannels
    object.Channel{n}.Measurement=scale(...
        object.Channel{n}.Measurement,value(n));
    object.PrivateBandwidth(n)=object.PrivateBandwidth(n)/value(n);
    if ~isempty(object.PrivateNoiseSpectrum{n})
        object.PrivateNoiseSpectrum{n}=scale(...
            object.PrivateNoiseSpectrum{n},1/value(n));
    end
    object.PrivateOffsetFrequency(n)=object.PrivateOffsetFrequency(n)/value(n);
    object=partition(object,'Points',...
        [object.Partition.Points object.Partition.Skip]);
    object.SampleRate(n)=object.SampleRate(n)/value(n);
    if ~isempty(object.PrivateSpectrogram(n))
        object.PrivateSpectrogram{n}=scale(object.PrivateSpectrogram{n},...
            'Grid1',value(n));
        object.PrivateSpectrogram{n}=scale(object.PrivateSpectrogram{n},...
            'Grid2',1/value(n));
        object.SpectrogramSettings.Partition.Duration=...
            object.SpectrogramSettings.Partition.Duration*value(n);
        object.SpectrogramSettings.Partition.Advance=...
            object.SpectrogramSettings.Partition.Advance*value(n);
    end
    object.PrivateWavelength(n)=object.PrivateWavelength(n)*value(n);
end

object.ReferenceSelection=object.ReferenceSelection*value(1);
if CommonScale
    for k=1:numel(object.ROIselection)
        table=object.ROIselection(k).Data;
        table(:,1)=table(:,1)*value(1);
        object.ROIselection(k)=define(object.ROIselection(k),table);
    end
    
    for n=1:object.NumberHistories
        object.History{n}=scale(object.History{n},value(1));
        object.HistorySettings.Partition.Duration=...
            object.HistorySettings.Partition.Duration*value(1);
        object.HistorySettings.Partition.Advance=...
            object.HistorySettings.Partition.Advance*value(1);
    end
else
    object.ROIselection=[];
    object.History=[];
    object.HistorySettings=[];
    object=changeStatus(object,'obsolete','ROI','History');
    warning('PDV:multiScale',...
        'Channel-specific scaling resets ROI selection(s) and histories');
end

end

function value=chooseScaleLegacy(previous,name)

db=SMASH.MUI.Dialog();
db.Hidden=true;
db.Name='PDV time scale';

h=addblock(db,'text',name,20);
set(h,'FontWeight','bold');

N=numel(previous);
for n=1:N
    h=addblock(db,'edit',sprintf('Channel %d scale:',n),20);
    EditBox(n)=h(2); %#ok<AGROW>
    temp=sprintf('%g',previous(n));
    set(h(2),'String',temp,'UserData',temp,'Callback',@checkValue);
end
    function checkValue(src,~)
        temp=get(src,'String');
        [junk,~,~,next]=sscanf(temp,'%g',1);
        if isempty(junk) || (junk <= 0)
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

CommonCheck=addblock(db,'checkbox','Common scale');
set(CommonCheck,'Callback',@changeCommon);
if N == 1
    set(CommonCheck,'Enable','off')
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

button=addblock(db,'button',{'OK' 'Cancel'});
set(button(1),'Callback',@ok);
    function ok(varargin)
        temp=probe(db);
        temp=temp(1:end-1);
        value=zeros(size(temp));
        for nn=1:numel(temp)
            value(nn)=sscanf(temp{nn},'%g',1);
        end
        delete(button(1));
    end
set(button(2),'Callback',@cancel);
    function cancel(varargin)
        delete(button(1));
    end

value=[];
locate(db,'center');
db.Modal=true;
show(db);
waitfor(button(1));
delete(db);

end

%%
function value=chooseScale(previous,name)

cb=SMASH.MUI2.ComponentBox();
setName(cb,'PDV time scale');

h=addMessage(cb,numel(name));
set(h,'FontWeight','bold','Text',name);
newRow(cb);

setLabelPosition(cb,'above');
N=numel(previous);
for n=1:N
    h=addEdit(cb,15);
    set(h(1),'Text',sprintf('Channel %d scale:',n));
    if n == 1
        EditBox=repmat(h(2),[1 N]);
    else
        EditBox(n)=h(2);
    end
    temp=sprintf('%g',previous(n));
    set(h(2),'Value',temp,'UserData',temp,'ValueChangedFcn',@checkValue);
end
newRow(cb);

label='Common scale';
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

value=ones(1,N);
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