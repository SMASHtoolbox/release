% plot Plot object data
%
% This method plots object data in a new figure.  Several plot modes are
% provided.
%    plot(object,'signal'); % time-domain signal (default)
%    plot(object,'amplitude'); % effective time-domain amplitude
%    plot(object,'window'); % time-domain window and its frequency-domain representation
%    plot(object,'noise');  % frequency-domain noise spectrum
%    plot(object,'preview',name,value,...); % reduction preview
%    plot(object,'reduction',name,value,...); % frequency reduction
% Preview and reduction plots accept optional name/value pairs for
% additional control.  Valid options include:
%    -'Index', which indicates the result be plotted. The most recent
%    result is used by default (index=0).  An offset from the most recent
%    result (index < 0) or the first result (index > 0) can also be
%    specified.  For example, the second result in a group of five is
%    indexed as +2 or -3.
%    -'Cutoff', which controls the minimum quality factor (dB)
%    displayed in the plot.  The default value is 0.
%
% NOTE: separate figures are generated for object array plotting. 
%
% See also SFR, estimateNoise, reduce, preview
%
function plot(object,mode,varargin)

% manage input
if (nargin < 2) || isempty(mode) || strcmpi(mode,'signal')
    mode='signal';
else
    assert(ischar(mode),'ERROR: invalid plot mode');
    mode=lower(mode);
end

option=struct('Index',0,'Cutoff',nan);
option=SMASH.Developer.options2struct(option,varargin{:});
assert(testNumber(option.Cutoff),...
    'ERROR: invalid SNR cutoff');

% deal with object arrays
if ~isscalar(object)
    for n=1:numel(object)
        plot(object(n),mode,index);
    end
    return
end

% generate requested plot
new=SMASH.MUI.Figure('Visible','off');
box on;
switch mode
    case 'signal'
        if numel(object.Time) > 1e6
            warning('Large signal plots may be slow');
        end
        plot(object.Time,object.Signal);
        xlabel('Time');   
        ylabel('Value');
        title(sprintf('%s signal',object.Name),'Interpreter','none');
    case 'amplitude'
        if isempty(object.PrivateAmplitude)
            fprintf('Estimating signal amplitude...');
            [~]=estimateAmplitude(object);
            fprintf('done\n');
        end
        data=object.PrivateAmplitude;
        plot(data(:,1),data(:,2));
        xlabel('Time');
        ylabel('Effective amplitude');
        title(sprintf('%s amplitude',object.Name),'Interpreter','none');       
        yb(1)=0;
        yb(2)=1.1*max(data(:,2));
        ylim(yb);
    case 'window'
        [time,window,frequency,transform]=evaluateWindow(object);
        subplot(2,1,1);
        time=time*object.FullTime;
        plot(time,window,'k');
        xlabel('Time');
        ylabel('Value');
        title(sprintf('%s window function',object.Name),...
            'Interpreter','none');
        subplot(2,1,2);
        frequency=frequency*object.SampleRate;
        plot(frequency,real(transform),frequency,imag(transform));
        xlabel('Frequency');
        ylabel('Amplitude');
        legend('Window','Conjugate');
        title(sprintf('%s window transforms',object.Name),...
            'Interpreter','none');
    case 'noise'
        fn=linspace(0,+0.5,1000);
        power=object.Noise.ShapeFcn(fn);
        f=object.SampleRate*fn;
        plot(f,power/trapz(f,power),'k');
        set(gca,'YScale','log');
        xlim([0 object.SampleRate/2])
        xlabel('Frequency');
        ylabel('Normalized noise power');
        title(sprintf('%s RMS noise= %#.2g',object.Name,object.Noise.RMS),...
            'Interpreter','none');
        xline(object.FrequencyBand(1),'Color','r','LineStyle','--');
        xline(object.FrequencyBand(2),'Color','r','LineStyle','--');
    case 'preview'
        if isempty(object.Preview)
            warning('No preview available for %s',object.Name);
            delete(new.Handle);
            return
        end
        try
            [result,label]=getResult(object,'preview',option.Index);
        catch ME
            throwAsCaller(ME);
        end
        if isempty(result.Data)
            warning('No plot generated because %s preview %s is empty',...
                object.Name,label);
            delete(new.Handle);
            return
        end
        generatePatches(object,result,option.Cutoff);
        title(sprintf('%s preview %s',object.Name,label),...
            'Interpreter','none');       
    case 'selection'
        if isempty(object.Selection)
            warning('No selection available for %s',object.Name);
            delete(new.Handle);
            return
        end
        view(object.Selection);
        xlabel('Time');
        ylabel('Frequency');
        if isscalar(object.Selection)
            title(sprintf('%s ROI selection',object.Name),...
                'Interpreter','none');
        else
            title(sprintf('%s ROI selections',object.Name),...
                'Interpreter','none');
        end
        if strcmpi(object.Mirror,'on')
            ylim([-1 +1]*object.FrequencyBand(2));
        else
            ylim(object.FrequencyBand);
        end
    case 'reduction'
        if isempty(object.Reduction)
            warning('No reduction available for %s',object.Name);
            delete(new.Handle);
            return            
        end
        try
            [result,label]=getResult(object,'reduction',option.Index);
        catch ME
            throwAsCaller(ME);
        end
        if isempty(result.Data)
            warning('Empty reduction--no plot generated');
            delete(new.Handle);
            return
        end
        generatePatches(object,result,option.Cutoff);
        title(sprintf('%s reduction %s',object.Name,label),...
            'Interpreter','none');
        axis tight;
    otherwise
        delete(new.Handle);
        error('ERROR: invalid plot mode');
end

ha=findobj(gcf,'Type','axes');
for n=1:numel(ha)
    label=get(ha(n),'XLabel');
    if strcmp(label.String,'Time') && ~isempty(object.Units.Time)
        label=sprintf('%s (%s)',label.String,object.Units.Time);
        xlabel(ha(n),label);
    elseif strcmp(label.String,'Frequency') && ~isempty(object.Units.Frequency)
        label=sprintf('%s (%s)',label.String,object.Units.Frequency);
        xlabel(ha(n),label);
    end
    label=get(ha(n),'YLabel');
    if strcmp(label.String,'Frequency') && ~isempty(object.Units.Frequency)
        label=sprintf('%s (%s)',label.String,object.Units.Frequency);
        ylabel(ha(n),label);
    end
end

figure(new.Handle);

end