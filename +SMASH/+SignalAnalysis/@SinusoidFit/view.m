% view Plot sinusoid data
%
% This method plots various types of sinusoid data.
%    view(object,mode);
% Valid modes include:
%    -'signal' shows the source and result signals
%    -'spectrum' shows the full and remainder spectra
%
% See also SinusoidFit
%

%
% created February 25, 2020 by Daniel Dolan (Sandia National Laboratories)
%
function varargout=view(object,mode)

% manage input
if (nargin < 2) || isempty(mode)
    mode='spectrum';
else
    assert(ischar(mode),'ERROR: invalid view mode');
end

% generate plot(s)
switch lower(mode)
    case 'signal'
        h(1)=view(object.Source);
        h(2)=view(object.Result,gca);
    case 'spectrum'
        SMASH.MUI.Figure;
        label={'Full spectrum' 'Remainder'};
        for n=1:2            
            subplot(2,1,n);
            if n == 1
                ha=gca;
            else
                ha(end+1)=gca;
            end
            view(split(object.Spectrum,n),gca);
            xlabel('Frequency');
            ylabel('Transform');
            legend('Real','Imaginary','Location','best');
            title(label{n},'FontWeight','normal');
        end        
        linkaxes(ha,'x');
        h=findobj(gcf,'Type','line');
        h=h(end:-1:1);
    case 'peaks'       
        view(split(object.Spectrum,1));       
        hleg=legend();
        hleg.AutoUpdate='off';
        f0=summarize(object);
        N=numel(f0);       
        for n=1:N
            xline(f0(n),'Color','k','LineStyle','--');
        end
    otherwise
        error('ERROR: ''%s'' is an invalid view mode',mode);
end

% manage output
if nargout > 0
    varargout{1}=h;
end

end