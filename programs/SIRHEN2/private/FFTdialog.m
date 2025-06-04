function data=FFTdialog(data,MainFigure)

db=SMASH.MUI.Dialog();
db.Hidden=true;
db.Name='FFT options';

list={'Hann' 'Boxcar' 'Hamming'};
for index=1:numel(list)
    if strcmpi(list{index},data.FFTwindow)
        break
    end
end
h=addblock(db,'listbox','Transform window',list,20);
set(h(1),'FontWeight','bold');
set(h(2),'Value',index);


NumFrequency=addblock(db,'edit',' ',20);
set(NumFrequency(1),'String','Num. frequencies [min max]',...
    'FontWeight','bold');
temp=sprintf('%g %g',data.FFTbins);
set(NumFrequency(2),'String',temp,'UserData',temp,...
    'Callback',@checkNumFrequency)
    function checkNumFrequency(varargin)              
        report=probe(db);    
        value=sscanf(report{2},'%g');
        if isempty(value)
            set(NumFrequency(2),'String',get(NumFrequency(2),'UserData'));
            return
        end
        if numel(value) < 2
            value(2)=inf;
        end
        value=round(sort(value(1:2)));
        if ~isfinite(value(1))
            set(NumFrequency(2),'String',get(NumFrequency(2),'UserData'));
            return
        end
        value(1)=max(value(1),100);
        value(2)=max(value(2),2*value(1));        
        temp=sprintf('%g %g',value);                     
        set(NumFrequency(2),'String',temp,'UserData',temp);
    end

h=addblock(db,'check','Show negative frequencies');
if data.ShowNegativeFrequencies
    set(h(1),'Value',1);
end

button=addblock(db,'button',{'Done' 'Cancel'});
set(button(1),'Callback',@done);
    function done(varargin)
        report=probe(db);  
        data.FFTwindow=lower(report{1});
        data.FFTbins=sscanf(report{2},'%g');
        data.ShowNegativeFrequencies=report{3};
        delete(button(1));
    end
set(button(2),'Callback',@cancel);
    function cancel(varargin)
        delete(button(1));
    end

locate(db,'center');
SMASH.Graphics.FigureTools.focus(db.Handle);
return2main=onCleanup(@() figure(MainFigure));
show(db);

waitfor(button(1));
delete(db);

end