% view View spectrograms, histories, or signals
%
% This method displays time-dependent data in a PDV object.  The default
% mode displays spectrograms.
%    view(object); % time-velocity spectrogram
%    view(object,'spectrogram'); % same as above
%    view(object,'raw'); % time-frequency spectrogram
% Signals may be displayed as well.
%    view(object,'signal');
%
% Defined region of interest selections may be displayed on top of the
% spectrograms.
%    view(object,'roi');
% An error is generated if no ROI selections have been made.
%
% Completed histories may be shown in various forms.
%    view(object,'history'); % velocitity, uncertainty, and signal amplitude
%    view(object,'velocity'); % velocity and uncertainty
%    view(object,'amplitude'); % signal amplitude
%    view(object,'overlay'); % velocity overlaid on spectrogram
% Incomplete or obsolete histories generate an error.  Obsolete histories
% can be displayed manually.
%    view(object.History{n}); % display n-th history (SignalGroup object)
%
% All visualization modes are drawn in a new figure by default.  Graphics
% can also be drawn in an existing figure, uipanel, or uitab object.
%    view(object,mode,target);
%
% Graphic handles are returned as outputs, as requested.
%    [h,haxes]=view(...);
% The first output is an array of line/image handles, dependening on the
% view mode.  The second output is an array of axes handles.
%
% See also PDV, generateHistory, generateSpectrogram
%

%
% created February 8, 2018 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode,target)

% manage input
if (nargin<2) || isempty(mode)
    mode='spectrogram';
end
assert(ischar(mode),'ERROR: invalid mode');
mode=lower(mode);
if strcmp(mode,'all') % this mode is for debugging only
    list={'signal' 'spectrogram' 'raw' 'history' 'velocity' 'amplitude' 'roi' 'overlay'};
    for n=1:numel(list)
        view(object,list{n});
    end
    return
end

if nargin < 3
    target=[];
else
    assert(ishandle(target),'ERROR: invalid target handle');
    switch lower(target.Type)
        case {'figure' 'uipanel' 'uitab'}
            % keep going
        otherwise
            error('ERROR: target must be a figure, uipanel, or uitab object');
    end    
end

% make sure data is available
switch mode
    case 'signal'
        % nothing to do
    case {'spectrogram' 'raw'}                
        assert(~strcmpi(object.Status.Spectrogram,'incomplete'),...
            'ERROR: spectrogram has not been generated');
    case {'history' 'velocity' 'amplitude'}
        switch lower(object.Status.History)
            case 'incomplete'
                error('ERROR: history has not been generated');
            case 'obsolete'
                warning('PDV:obsolete','PDV results may be obsolete');
        end   
    case 'roi'
       assert(strcmpi(object.Status.ROI,'complete'),...
           'ERROR: region of interest has not been selected'); 
       assert(strcmpi(object.Status.Spectrogram,'complete'),...
           'ERROR: spectrogram has not been generated');
    case 'overlay'
        assert(strcmpi(object.Status.Spectrogram,'complete'),...
            'ERROR: spectrogram has not been generated');
        switch lower(object.Status.History)
            case 'incomplete'
                error('ERROR: history has not been generated');
            case 'obsolete'
                warning('PDV:obsolete','PDV results may be obsolete');
        end
    case {'noise' 'noisespectrum'}
        assert(strcmpi(object.Status.Noise,'complete'),...
            'ERROR: noise has not been performed');
    otherwise
        error('ERROR: invalid view mode');
end

if isempty(target)
    fig=SMASH.MUI.Figure();
    fig.Hidden=true;    
    target=fig.Handle;
    set(target,'Units','normalized','Position',[0 0 1 1]);
    pos=getpixelposition(target);    
    L=min(pos(3:4));
    pos(4)=0.75*L;
    pos(3)=pos(4);
    set(target,'Units','pixels','Position',pos);
    movegui(target,'center');
    fig.Hidden=false;
end

% manage tabs
parent=target;
if strcmpi(target.Type,'uitab')
    TabGroup=target.Parent;
else
    TabGroup=uitabgroup('Parent',parent);
    target=uitab(TabGroup,'Title','Plots');
end
TabGroup.TabLocation='bottom';

% generate plot
switch lower(mode)
    case 'signal'
        for n=1:object.NumberChannels
            temp=axes('Parent',target);
            subplot(object.NumberChannels,1,n,temp);
            box on;
            if n == 1
                h=view(object.Channel{n},temp);
                h=repmat(h,size(object.Channel));
                haxes=repmat(temp,size(object.Channel));
            else
                h(n)=view(object.Channel{n},temp);
                haxes(n)=temp;
            end
            xlabel(haxes(n),object.Channel{n}.Measurement.GridLabel);            
            ylabel(haxes(n),object.Channel{n}.Measurement.DataLabel);
            generateTitle(haxes(n),n) 
        end     
        addSettingTab('source');
    case 'spectrogram'       
        for n=1:object.NumberChannels
            temp=axes('Parent',target);
            subplot(object.NumberChannels,1,n,temp);
            box on;
            if n == 1
                h=view(object.Spectrogram{n},'show',temp);
                h=repmat(h,size(object.Channel));
                haxes=repmat(temp,size(object.Channel));
            else
                h(n)=view(object.Spectrogram{n},'show',temp);
                haxes(n)=temp;
            end
            xlabel(haxes(n),object.Spectrogram{n}.Grid1Label);
            ylabel(haxes(n),object.Spectrogram{n}.Grid2Label);
            generateTitle(haxes(n),n)   
        end
        addSettingTab('source','spectrogram');
    case 'raw'        
        for n=1:object.NumberChannels
            haxes=axes('Parent',target);
            subplot(object.NumberChannels,1,n,haxes);
            box on;
            temp=object.PrivateSpectrogram{n};
            if ~object.ShowNegativeFrequencies
                temp=crop(temp,[],[0 inf]);          
            end
            if n == 1
                h=view(temp,'show',haxes);
                h=repmat(h,size(object.Channel));
                haxes=repmat(haxes,size(object.Channel));
            else
                h(n)=view(temp,'show',haxes);
                haxes(n)=haxes;
            end
            xlabel(haxes(n),object.PrivateSpectrogram{n}.Grid1Label);
            ylabel(haxes(n),object.PrivateSpectrogram{n}.Grid2Label);
            generateTitle(haxes(n),n)                  
        end
        addSettingTab('source','spectrogram');
    case 'roi'
        for n=1:object.NumberChannels
            haxes=axes('Parent',target);
            subplot(object.NumberChannels,1,n,haxes);
            box on;
            if n == 1
                h=view(object.Spectrogram{n},'show',haxes);
                h=repmat(h,size(object.Channel));
                haxes=repmat(haxes,size(object.Channel));
            else
                h(n)=view(object.Spectrogram{n},'show',haxes);
                haxes(n)=haxes;
            end
            xlabel(haxes(n),object.Spectrogram{n}.Grid1Label);
            ylabel(haxes(n),object.Spectrogram{n}.Grid2Label);
            generateTitle(haxes(n),n)   
            for m=1:numel(object.ROIselection)
                view(object.ROIselection(m),haxes);
            end
        end                
        addSettingTab('source','spectrogram');        
    case 'history'
        color=lines(object.NumberHistories);        
        haxes(1)=axes('Parent',target);
        subplot(3,1,1,haxes(1));
        for n=1:object.NumberHistories
            h(1,n)=view(object.History{n},1,haxes(1));  %#ok<AGROW>
            set(h(1,n),'Color',color(n,:));
        end
        xlabel(haxes(1),object.Label.Time);
        ylabel(haxes(1),object.Label.Velocity);
        title(haxes(1),object.Name,'HorizontalAlignment','right',...
            'Units','normalized','Position',[1 1]);
        legend(generateLabel(),'Location','best');
        haxes(2)=axes('Parent',target);
        subplot(3,1,2,haxes(2));
        for n=1:object.NumberHistories
            h(2,n)=view(object.History{n},2,haxes(2));
            set(h(2,n),'Color',color(n,:));
        end
        xlabel(haxes(2),object.Label.Time);
        ylabel(haxes(2),object.Label.Uncertainty);
        title(haxes(2),object.Name,'HorizontalAlignment','right',...
            'Units','normalized','Position',[1 1]);
        legend(generateLabel(),'Location','best');
        haxes(3)=axes('Parent',target);
        subplot(3,1,3,haxes(3));
        for n=1:object.NumberHistories
            h(3,n)=view(object.History{n},3,haxes(3));
            set(h(3,n),'Color',color(n,:));
        end
        xlabel(haxes(3),object.Label.Time);
        ylabel(haxes(3),object.Label.Amplitude);
        title(haxes(3),object.Name,'HorizontalAlignment','right',...
            'Units','normalized','Position',[1 1]);
        legend(generateLabel(),'Location','best');
        set(haxes,'Box','on');
        addSettingTab('source','history');
    case 'velocity'        
        color=lines(object.NumberHistories);
        haxes(1)=axes('Parent',target);
        subplot(2,1,1,haxes(1));
        for n=1:object.NumberHistories
            h(1,n)=view(object.History{n},1,haxes(1));  %#ok<AGROW>
            set(h(1,n),'Color',color(n,:));
        end
        xlabel(haxes(1),object.Label.Time);
        ylabel(haxes(1),object.Label.Velocity);
        title(haxes(1),object.Name,'HorizontalAlignment','right',...
            'Units','normalized','Position',[1 1]);
        legend(generateLabel(),'Location','best');
        haxes(2)=axes('Parent',target);
        subplot(2,1,2,haxes(2));
        for n=1:object.NumberHistories
            h(2,n)=view(object.History{n},2,haxes(2));
            set(h(2,n),'Color',color(n,:));
        end
        xlabel(haxes(2),object.Label.Time);
        ylabel(haxes(2),object.Label.Uncertainty);
        title(haxes(2),object.Name,'HorizontalAlignment','right',...
            'Units','normalized','Position',[1 1]);
        legend(generateLabel(),'Location','best');
        set(haxes,'Box','on');
        addSettingTab('source','history');
    case 'amplitude' % diagnostic       
        color=lines(object.NumberHistories);
        haxes=axes('Parent',target,'Box','on');
        for n=1:object.NumberHistories
            h(1,n)=view(object.History{n},3,haxes);  %#ok<AGROW>
            set(h(1,n),'Color',color(n,:));
        end
        xlabel(haxes,object.Label.Time);
        ylabel(haxes,object.Label.Amplitude);
        title(haxes,object.Name,'HorizontalAlignment','right',...
            'Units','normalized','Position',[1 1]);
        legend(generateLabel(),'Location','best');
        addSettingTab('source','history');
    case 'overlay'       
        [~,haxes]=view(object,'Spectrogram',target);
        for m=1:object.NumberChannels
            for n=1:object.NumberHistories
                temp=split(object.History{n});
                temp.GraphicOptions.LineWidth=2;
                temp.GraphicOptions.LineColor='w';  
                h(1,n)=view(temp,haxes(m));
                temp.GraphicOptions.LineColor='k';
                temp.GraphicOptions.LineStyle='--';
                view(temp,haxes(m));
            end
        end
        addSettingTab('history');
    case {'noise' 'noisespectrum'}
        for n=1:object.NumberChannels
            temp=axes('Parent',target);
            subplot(object.NumberChannels,1,n,temp);
            box on;
            if n == 1
                h=view(object.NoiseSpectrum{n},temp);
                h=repmat(h,size(object.Channel));
                haxes=repmat(temp,size(object.Channel));
            else
                h(n)=view(object.NoiseSpectrum{n},temp);
                haxes(n)=temp;
            end
            xlabel(haxes(n),object.Spectrogram{n}.Grid2Label);
            ylabel(haxes(n),'Power density profile');
            generateTitle(haxes(n),n)           
        end
        addSettingTab('source','spectrogram');
end

if strcmpi(mode,'spectrogram')
    linkaxes(findobj(parent,'Type','axes'),'xy');
else
    linkaxes(findobj(parent,'Type','axes'),'x');
end

%%
    function generateTitle(haxes,index)        
        if numel(object.Channel) == 1
            name=object.Name;
        else
            name=sprintf('%s, channel %d',object.Name,index);
        end        
        title(haxes,name,'HorizontalAlignment','right',...
            'Units','normalized','Position',[1 1],'Interpreter','none');
    end

    function label=generateLabel()
        label=cell(size(object.ROIselection));
        for nn=1:numel(object.ROIselection)
            label{nn}=object.ROIselection(nn).Name;
        end
    end

    function addSettingTab(varargin)
        for kk=1:nargin
            switch lower(varargin{kk})
                case 'source'
                    new=uitab('Parent',TabGroup,...
                        'Title','Source data','Tag','SourceFiles');
                    hc=uicontrol('Parent',new,'Style','text',...
                        'Units','normalized','OuterPosition',[0 0 1 1]);
                    temp=generateDataSource(object);
                    hc.String=temp;
                    hc.HorizontalAlignment='left';
                    hc.BackgroundColor='w';
                case 'spectrogram'
                    new=uitab('Parent',TabGroup,...
                        'Title','Spectrogram settings','Tag','SpectrogramSettings');
                    hc=uicontrol('Parent',new,'Style','text',...
                        'Units','normalized','OuterPosition',[0 0 1 1]);
                    hc.String=SMASH.General.dumpStructure(object.SpectrogramSettings);
                    hc.HorizontalAlignment='left';
                    hc.BackgroundColor='w';
                case 'history'
                    new=uitab('Parent',TabGroup,'Title','History settings',...
                        'Tag','HistorySettings');
                    hc=uicontrol('Parent',new,'Style','text',...
                        'Units','normalized','OuterPosition',[0 0 1 1]);
                    hc.String=SMASH.General.dumpStructure(object.HistorySettings);
                    hc.HorizontalAlignment='left';
                    hc.BackgroundColor='w';
            end
        end
    end

%% manage output
if nargout > 0
    varargout{1}=h;
    varargout{2}=haxes;
end

end

%%
function data=generateDataSource(object)

list={};
for n=1:object.NumberChannels
    list{end+1}=sprintf('Channel %02d',n); %#ok<AGROW>
    temp=object.Channel{n}.Measurement.Source;
    if ~strncmpi(temp,'File import:',12)
        list{end+1}=temp; %#ok<AGROW>
        continue
    end
    start=strfind(temp,':')+1;
    stop=strfind(temp,'(')-1;    
    list{end+1}=sprintf('   File: %s',strtrim(temp(start:stop))); %#ok<AGROW>
    start=stop+2;
    stop=strfind(temp,')')-1;
    list{end+1}=sprintf('   Record: %s',strtrim(temp(start:stop))); %#ok<AGROW>
    start=strfind(temp,',')+1;   
    list{end+1}=sprintf('   Format: %s',strtrim(temp(start:end))); %#ok<AGROW>
end

width=0;
for n=1:numel(list)
    width=max(width,numel(list{n}));
end

format=sprintf('%%-%ds \\n',width);
data=sprintf(format,list{:});

end