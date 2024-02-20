function object=HistoryDialog(object,SourceFigure)

setProgramFont()
db=SMASH.MUI.Dialog();
db.Hidden=true;
db.Name='History analysis';

Type=addblock(db,'list','Type',{'Power'},10,2);
set(Type(1),'FontWeight','bold');

Parameter=addblock(db,'table',{'Parameters' ' '},[10 10],4);
set(Parameter(1),'FontWeight','bold');
delete(Parameter(2));
set(Parameter(3),'Enable','off');

if isempty(object.ROIselection)   
    h=addblock(db,'text','No ROI selection',20);
    set(h,'BackgroundColor','y');      
else
    label=sprintf('Using %d ROI selections',numel(object.ROIselection));
    addblock(db,'text',label,20); 
end

GenerateButton=addblock(db,'button','Generate history',20);
set(GenerateButton(1),'Callback',@generateHistoryCallback)
    function generateHistoryCallback(varargin)
        h=findobj(db.Handle,'Enable','on');
        set(h,'Enable','off');
        pause(0.1);
        object=generateHistory(object);        
        set(h,'Enable','on');
    end

DoneButton=addblock(db,'button','Done');
set(DoneButton,'Callback',@(~,~) delete(DoneButton));

locate(db,'West',SourceFigure);
show(db);
SMASH.Graphics.FigureTools.focus(db.Handle);
waitfor(DoneButton);
delete(db);
figure(SourceFigure);

end