function func=MergeConfigs()

% prompt the user for mutliple config files
func={};
done=false;
while ~done
    %data=ParseConfig('');
    [data,status,filename]=ParseConfig('');
    if isempty(data) % user pressed cancel or choose an empty config file
        done=true;
        continue
    end
    [data,status]=InterpConfig(data,filename);
    if strcmp(status.exitmode,'normal')
        func=[func data];
    else
        done=true;        
    end
end

% Perform VISAR analysis on each record
N=numel(func);
for ii=1:N
    func{ii}=VisarAnalysis(func{ii});
    func{ii}.NewRecord=false;
    func{ii}.LineColor=DistinguishedLines(ii);
end