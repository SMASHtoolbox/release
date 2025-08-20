function object=import(object,data)

object.Name='SignalGroup object';
object.GraphicOptions=SMASH.General.GraphicOptions;
object.GraphicOptions.Marker='none';
object.GraphicOptions.LineStyle='-';
object.Source='File import';

% manage multiple imports
if numel(data) > 1 
    object=import(object,data(1));
    for k=2:numel(data)
        temp=import(object,data(k));
        object=gather(object,temp);
    end
    return
end

% manage individual imports
[~,name,ext]=fileparts(data.FileName);
object.Legend={[name ext]};
object.NumberSignals=1;

switch data.Format
    case 'column'
        data=data.Data;
        if size(data,2)==1
            object.Data=data(:,1);
            object.Grid=transpose(1:size(data,1));
        else
            object.Grid=data(:,1);
            object.Data=data(:,2:end);
        end
        object.NumberSignals=size(object.Data,2);
        object.Legend=cell(1,object.NumberSignals);
        for n=1:object.NumberSignals
            object.Legend{n}=sprintf('%s %d',[name ext],n);
        end
    case {'agilent','keysight','lecroy','tektronix','yokogawa','zdas'}
        object.Grid=data.Time;
        object.Data=data.Signal;
    case 'dig'
        object.Grid=data.Time;
        object.Data=data.Signal;
    case 'pff'
        errmsg{1}='ERROR: cannot import this dataset into a Signal object';
        if numel(data)>1
            errmsg{2}='     Multiple blocks detected';
            error('%s\n',errmsg{:});
        end
        switch data.PFFdataset
            case 'PFTUF1'
                object.Grid=data.X(:);
                object.Data=data.Data(:);
            case {'PFTUF3','PFTNF3','PFTNG3','PFTNI3'}
                object.Grid=data.X(:);
                object.Data=permute(data.Data,[2 1]);
                if numel(object.Grid) ~= numel(object.Data)
                    errmsg{2}='     Data is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
            case 'PFTNGD'
                if (numel(data.X) ~= 1)
                    errmsg{2}='     Grid is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
                object.Grid=data.X{1}(:);
                M=numel(data.Data);
                object.Data=nan(numel(object.Grid),M);
                for k=1:M
                    object.Data(:,k)=data.Data{k}(:);
                end
            otherwise
                errmsg{2}='     Unsupported dataset type';
                error('%s\n',errmsg{:});
        end
    case 'taf'
        object.Grid=data.Grid{1}(:);
        object.Data=data.Data;
        object.NumberSignals=size(object.Data,2);
    otherwise
        error('ERROR: cannot import Signal from this format');
end

end