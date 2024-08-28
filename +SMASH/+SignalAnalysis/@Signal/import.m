
function object=import(object,data)

object.Name='Signal object';
object.GraphicOptions=SMASH.General.GraphicOptions;
object.GraphicOptions.Marker='none';
object.GraphicOptions.LineStyle='-';
object.Source=sprintf('File import: %s',data.Summary);

% manage multiple imports
assert(numel(data)==1,...
    'ERROR: cannot import multiple records into a Signal object');

% manage individual imports
switch data.Format
    case 'column'
        data=data.Data;
        if size(data,2)==1
            object.Data=data(:,1);
            object.Grid=transpose(1:size(data,1));
        else
            object.Grid=data(:,1);
            object.Data=data(:,2);
        end             
    case {'acqiris','agilent','keysight','lecroy','tektronix','yokogawa'}
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
                object.Data=data.Data(:);
                if numel(object.Grid) ~= numel(object.Data)
                    errmsg{2}='     Data is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
            case 'PFTNGD'
                if (numel(data.X) ~= 1)
                    errmsg{2}='     Grid is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
                if (numel(data.Data) ~= 1)
                    errmsg{2}='     Data is not one-dimensional';
                    error('%s\n',errmsg{:});
                end
                object.Grid=data.X{1}(:);
                object.Data=data.Data{1}(:);
            otherwise
                errmsg{2}='     Unsupported dataset type';
                error('%s\n',errmsg{:});
        end
    case 'zdas'
        object.Grid=data.Time;
        object.Data=data.Signal;
    case 'taf'
        object.Grid=data.Grid{1}(:);
        object.Data=data.Data(:,1); % only use first column (readFile can access specific record)
    otherwise
        error('ERROR: cannot import Signal from this format');
end

object=verifyGrid(object);

end