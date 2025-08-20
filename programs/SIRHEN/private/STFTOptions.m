function STFTOptions(varargin)

% handle input
fig=varargin{3};
updatefunc=varargin{4};

% access data
data=get(fig,'UserData');

% prompt user
label{1}='Number time points:';
label{2}='Number frequency points:';
label{3}='Overlap ratio :';
label{4}='Window type:';
label{5}='Normalization:';
label{6}='DC removal:';
options.root=fig;
options.location='center';
default={data.Nduration(1), data.Nfreq(1), data.overlap, ...
         data.window, data.normalization, data.removeDC};
answer=datadlg_STFT('STFT parameters',label,default,options);
if isempty(answer)
    return
end

Nduration=sscanf(answer{1},'%d',1);
Nfreq=sscanf(answer{2},'%d',1);
overlap=max(0,sscanf(answer{3},'%g',1));
window=sscanf(answer{4},'%s',1);
normalization=sscanf(answer{5},'%s',1);
removeDC=answer{6};
if isempty(Nduration) || isempty(Nfreq) || isempty(overlap) || ...
           isempty(window) || isempty(normalization) || isempty(removeDC)
    STFTOptions([],[],varargin{:});
    return
end

% look for changes
changeA=(data.Nduration~=Nduration)|(data.overlap~=overlap)|(data.Nfreq(1)~=Nfreq);
changeB=~strcmp(data.window,window)| ~strcmp(data.normalization,normalization) ...
    | (data.removeDC~=removeDC);
if changeA || changeB
    data.update.fullSTFT=true;
    data.update.experimentSTFT=true;
    if changeB
        data.update.history=true;
    end
    data.Nduration=Nduration;
    data.Nfreq=Nfreq;
    data.overlap=overlap;
    data.window=window;
    data.normalization=normalization;
    data.removeDC=logical(removeDC); 
    set(fig,'UserData',data)
    feval(updatefunc,fig);
end