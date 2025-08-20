% This function manages file import for the SignalGroup creator.  A lot of
% the real effort is passed back to the Signal creator.

% created November 24, 2012
function object=ImportFile(object,filename,format)

% handle input
if ischar(filename)
    filename={filename};
end

for n=1:numel(filename)
    switch lower(format)
        case 'column'
            source=SMASH.FileAccess.ColumnFile(filename{n});
            data=read(source);
            new=feval(class(object),data(:,1),data(:,2:end)); % SignalGroup object
        case {'agilent','lecroy','tektronix','yokogawa'}
            source=SMASH.FileAccess.DigitizerFile(filename{n},format);
            content=probe(source);
            for m=1:content.NumberSignals
                temp=SMASH.SignalAnalysis.Signal('import',filename{n},format,m);
                if m==1
                    new=feval(class(object),temp.Grid,temp.Data); % SignalGroup object
                else
                    new=gather(new,temp);
                end
            end
        case 'dig'
            temp={SMASH.SignalAnalysis.Signal('import',filename{n},format)};
            new=feval(class(object),temp.Grid,temp.Data); % SignalGroup object
        case 'pff' % some work is needed here
            source=SMASH.FileAccess.PFFfile(filename{n});
            content=probe(source);
            for m=1:content.NumberSignals
                temp=SMASH.SignalAnalysis.Signal('import',filename{n},format,content(m).Label);
                if m==1
                    new=feval(class(object),temp.Grid,temp.Data); % SignalGroup object
                else
                    new=gather(new,temp);
                end
            end
        case 'sda' % some work needed here!
            source=SMASH.FileAccess.SDAfile(filename{n});
            content=probe(source,record);
            for m=1:content.NumberSignals
                temp=SMASH.SignalAnalysis.Signal('import',filename{n},format,content(m).Label);
                if m==1
                    new=feval(class(object),temp.Grid,temp.Data); % SignalGroup object
                else
                    new=gather(new,temp);
                end
            end
        otherwise
            error('ERROR: SignalGroup object cannot be created from requested format');
    end   
    if object.NumberSignals==0
        object.Grid=new.Grid;
        object.Data=new.Data;
        object.NumberSignals=new.NumberSignals;
    else
        object=gather(object,new);
    end
    
end

% access import file
object.Source='SignalGroup import';
object.SourceFormat=format;
object=revealProperty(object,'SourceFormat');

end