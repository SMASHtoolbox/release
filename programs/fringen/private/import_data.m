function data=import_data(data)

% read data from file
filename=data.inputfile;
try
    [temp,header,filename]=ColumnReader(filename);
    if isempty(temp)
        data=[];
        return
    end
catch
    errordlg('Unable to read history file');
end

data.inputfile=filename;

Ncol=size(temp,2);
if Ncol<2
    error('ERROR: insufficient data in file');
end

data.time=temp(:,1);
tsize=size(data.time);
data.velocity=temp(:,2);

if Ncol>=3
    data.IC=temp(:,3);
else
    data.IC=ones(tsize);
end

if Ncol>=4
    data.IE=temp(:,4);
else
    data.IE=zeros(tsize);
end

if Ncol>=5
    data.IR=temp(:,5);
else
    data.IR=ones(tsize);
end

% integrate velocity to find position
data.position=cumtrapz(data.time,data.velocity);