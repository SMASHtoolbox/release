function VisarData = LoadSignals(VisarData)
% LOADSIGNALS   Loads raw signals into PointVISAR
 
if numel(VisarData.InputFiles)==1
    filename=VisarData.InputFiles{1};
    [~,~,ext]=fileparts(filename);
    if strcmpi(ext,'.h5') % Agilent binary file
        [signal,time]=agilent_h5read(filename,1:VisarData.NumSignals);
        for ii=1:VisarData.NumSignals
            VisarData.RawSignalTime{ii}=time{ii};
            VisarData.SignalTime{ii}=time{ii};
            VisarData.RawSignal{ii}=signal{ii};
            VisarData.Signal{ii}=signal{ii};
        end
    elseif strcmpi(ext,'.taf') % Thrifty Array Format binary file        
        [data,grid]=SMASH.ThriftyAnalysis.ArrayFile.read(filename);
        time=grid{1};
        for ii=1:VisarData.NumSignals
            VisarData.RawSignalTime{ii}=time;
            VisarData.SignalTime{ii}=time;
            VisarData.RawSignal{ii}=data(:,ii);
            VisarData.Signal{ii}=data(:,ii);
        end

    else % text file
        data=ColumnReader(filename);
        for ii=1:VisarData.NumSignals
            VisarData.RawSignalTime{ii}=data(:,1);
            VisarData.SignalTime{ii}=data(:,1);
            VisarData.RawSignal{ii}=data(:,1+ii);
            VisarData.Signal{ii}=data(:,1+ii);
        end
    end
    
else % multiple input files (text or binary)
    for ii=1:VisarData.NumSignals
        filename=VisarData.InputFiles{ii};
        [~,~,extension]=fileparts(filename);
        switch lower(extension)
            case {'.txt','.dat','.csv','.asc'} % text files
                data=ColumnReader(filename);
                time=data(:,1);
                signal=data(:,2);
            case '.isf' % Tektronix binary file
                src=SMASH.SignalAnalysis.Signal(filename);
                time=src.Grid;
                signal=src.Data;
            case '.wfm' % Tektronix binary file
                %[time,signal]=wfmread(filename);
                [signal,time]=wfmread(filename);                
            case '.dig' % NTS binary file
                [signal,time]=digread(filename);
            case '.h5' % Agilent HDF5 files
                [signal,time]=agilent_h5read(filename);
            otherwise
                error('Error: \n %s \n does not match any known file type',...
                    filename);
        end
        VisarData.RawSignalTime{ii}=time;
        VisarData.SignalTime{ii}=time;
        VisarData.RawSignal{ii}=signal;
        VisarData.Signal{ii}=signal;
    end
end

% for ii=1:VisarData.NumSignals
%     if isempty(VisarData.InputFiles{ii}) % prompt user for missing file names
%         % preserve previous filterspec
%         for jj=1:Nspec
%             search=strfind(filterspec{jj,1},extension);
%             if isempty(search)
%                 % do nothing
%             else
%                 temp=filterspec(1,:);
%                 filterspec(1,:)=filterspec(jj,:);
%                 filterspec(jj,:)=temp;
%                 continue
%             end
%         end        
%         label=['Choose ' VisarData.SignalLabels{ii} ' file'];
%         [filename,pathname]=uigetfile(filterspec,label);
%         if isnumeric(filename) % user pressed cancel
%             cd(old);
%             return
%         end
%         filename=fullfile(pathname,filename);
%         cd(pathname);       
%         VisarData.InputFiles{ii}=filename;
%         [pathstr,name,extension]=fileparts(filename);        
%     end
%     [time,signal]=ReadDataFile(VisarData.InputFiles{ii});
%     VisarData.RawSignalTime{ii}=time;
%     VisarData.SignalTime{ii}=time;
%     VisarData.RawSignal{ii}=signal;
%     VisarData.Signal{ii}=signal;
% end
% cd(old);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [time, signal] = ReadDataFile(filename)
% READDATAFILE  Reads a data file containing a visar signal.

% Get the extension of the filename
[pathstr,name,extension]=fileparts(filename);

% Based on the type of signal file, call the appropriate read function
switch lower(extension)
    case {'.txt','.dat','.csv','.asc'} % text files
        data=ColumnReader(filename);
        time=data(:,1);
        signal=data(:,2);
    case '.wfm' % Tektronix binary file
        [time, signal] = wfmread(filename);
    otherwise
        errmsg = [filename ' does not match any known file type'];
        errordlg(errmsg,'File Error');
        return
end