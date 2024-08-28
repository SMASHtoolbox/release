function updateGUI(fig)

data=get(fig,'UserData');
h=guihandles(fig);

% extract file name
filename=data.inputfile;
[pname,fname,ext]=fileparts(filename);
filename=[fname ext];

% velocity plot
set(h.VelocityHistory,'XData',data.time,'YData',data.velocity,...
    'Visible','on');
message=sprintf('Velocity history (%s)',filename);
title(h.VelocityPlot,message,'Interpreter','none');

% intensity plot
set(h.CoherentHistory,'XData',data.time,'YData',data.IC,...
    'Visible','on');
set(h.EmissionHistory,'XData',data.time,'YData',data.IE,...
    'Visible','on');
switch data.mode
    case 'PDV'
        set(h.ReferenceHistory,'XData',data.time,'YData',data.IR,...
            'Visible','on');
        hline=[h.CoherentHistory h.EmissionHistory h.ReferenceHistory];
        label={'Coherent','Emission','Reference'};
    case 'VISAR'
        set(h.ReferenceHistory,'XData',nan,'YData',nan,'Visible','off');
        hline=[h.CoherentHistory h.EmissionHistory];
        label={'Coherent','Emission'};
end
legend(hline,label,'Location','best');
message=sprintf('Intensity history (%s)',filename);
title(h.IntensityPlot,message,'Interpreter','none');

% signal plot
Nsignal=numel(data.signal);
Nmax=6;
if Nsignal>Nmax
    % issue a warning
end

Nactive=min([Nsignal Nmax]);
hline=zeros(1,Nactive);
label=cell(1,Nactive);
for n=1:Nmax
    tag=sprintf('SignalHistory%d',n);
    if n<=Nactive
        set(h.(tag),'XData',data.time,'YData',data.signal{n},'Visible','on');
        hline(n)=h.(tag);
        label{n}=sprintf('Signal %d',n);
    else
        set(h.(tag),'XData',nan,'YData',nan,'Visible','off');
    end
end
legend(hline,label,'Location','best');

message=sprintf('Calculated %s signal(s)',data.mode);
title(h.SignalPlot,message);
