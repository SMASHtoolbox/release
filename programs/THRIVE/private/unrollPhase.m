function unrollPhase(~,~,fig)

%%
% prompt users for information
dlg=SMASH.MUI.Dialog;
dlg.Hidden=true;
dlg.Name='Unroll phase';

%addblock(dlg,'text','"Unroll" is a crude but robust three-phase analysis');

FringeConstant=addblock(dlg,'edit','Fringe constant:');
set(FringeConstant(2),'String','775e-9','UserData','775e-9',...
    'Callback',@verifyDPF);
    function verifyDPF(varargin)
        value=get(FringeConstant(2),'String');
        value=sscanf(value,'%g',1);
        if isempty(value)
            set(FringeConstant(2),'String',get(FringeConstant(2),'UserData'));
        else
            new=sprintf('%g',value);
            set(FringeConstant(2),'String',new,'UserData',new);
        end
    end

DPF=[];
h=addblock(dlg,'button',{'OK' 'Cancel'});
set(h(1),'Callback',@OK);
    function OK(varargin)
        DPF=get(FringeConstant(2),'String');
        DPF=sscanf(DPF,'%g',1);
        delete(dlg);
    end
set(h(2),'Callback',@cancel);
    function cancel(varargin)
        delete(dlg);
    end

locate(dlg,'center',fig);
dlg.Hidden=false;
dlg.Modal=true;
uiwait(dlg.Handle);
if isempty(DPF)
    return
end

%%
% extract data from figure
h=guihandles(fig);
t=get(h.D1,'XData');
t=t(:);
table=nan(numel(t),3);
table(:,1)=get(h.D1,'YData');
table(:,2)=get(h.D2,'YData');
table(:,3)=get(h.D3,'YData');

% unroll phase
[~,Q]=min(table,[],2); 

index=[1; find(Q(2:end) ~= Q(1:end-1))+1];
left=index(1:end-1);
right=index(2:end);
time=(t(left)+t(right))/2;

position=nan(size(time));
forward=(...
    ( (Q(left)==1) & (Q(right)==2)) | ...
    ( (Q(left)==2) & (Q(right)==3)) | ...
    ( (Q(left)==3) & (Q(right)==1)) );
position(forward)=+1/3;
position(~forward)=-1/3;

position=cumsum(position);

position=SMASH.SignalAnalysis.Signal(time,position);
position=-DPF*position;
position.GridLabel='Time';
position.DataLabel='Position';

view(position);

end